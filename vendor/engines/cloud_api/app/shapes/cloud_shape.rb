class CloudShape

  cattr_reader :scopes do
    {}
  end

  class << self

    def shape(source, *shape)
      options = shape.extract_options!
      shape   = shape.flatten.compact.uniq.reduce({}) { |memo, item| memo[item.to_sym] = nil ; memo }.merge(options)

      sources = [source]
        .flatten
        .compact
        .group_by { |source| source.class }
        .map do |key, sources|
          shaper          = "#{key}_shape".classify.constantize rescue self
          shaped_sources  = sources.map { |source| shaper.new(source) }

          case
          when key < ActiveRecord::Base
            shaper.process_AR(shaped_sources, shape)
          else
            sources
          end

        end
        .flatten

      source.respond_to?(:each) ? sources : sources.first
    end

  protected

    def scope(key, &block)
      if block_given?
        scopes[key.to_sym] = block
      else
        scopes[key.to_sym]
      end
    end


    def process_AR(sources, shape)
      source_ids  = sources.map(&:uuid)
      data        = source_ids.reduce({}) { |memo, id| memo[id] = { id: id } ; memo }

      shape.each do |key, subshape|
        if current_scope = scope(key)
          current_scope.call(sources, subshape).each do |uuid, child|
            data[uuid][key] = child
          end
        else
          sources.each do |source|
            data[source.uuid][key] = shape(source.public_send(key), subshape)
          end
        end
      end

      data.values
    end

  end



  def initialize(source)
    @source = source
  end


  def controller_helpers
    ActionController::Base.helpers
  end


  def method_missing(name, *args, &block)
    if @source.respond_to?(name)
      @source.public_send(name, *args, &block)
    elsif controller_helpers.respond_to?(name)
      controller_helpers.public_send(name, *args, &block)
    else
      super
    end
  end


  def respond_to_missing?(name)
    @source.respond_to?(name) || controller_helpers.respond_to?(name) || super
  end


end
