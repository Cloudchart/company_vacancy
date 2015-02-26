class CloudShape

  cattr_reader :scopes do
    {}
  end

  class << self

    def shape(source, *shape)
      shape   = shape.flatten.compact.uniq
      options = shape.extract_options!
      shape   = shape.reduce({}) { |memo, item| memo[item.to_sym] = nil ; memo }.merge(options)

      sources = [source]
        .flatten
        .compact
        .uniq
        .group_by { |source| source.class }
        .map do |key, sources|
          case
          when key < ActiveRecord::Base
            shaper = "#{key}_shape".classify.constantize rescue self
            shaper.process_AR(key, sources, shape)
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
        attr_accessor key
        scopes[key.to_sym] = block
      else
        scopes[key.to_sym]
      end
    end


    def preloader_AR
      @preloader ||= ActiveRecord::Associations::Preloader.new
    end


    def process_AR(klass, sources, shape)
      shaped_sources  = sources.map { |source| new(source) }
      data            = sources.reduce({}) { |memo, source| memo[source.uuid] = { id: source.uuid } ; memo }

      shape.each do |key, subshape|

        if current_scope = scope(key)
          current_scope.call(shaped_sources, subshape)
        elsif klass.reflect_on_association(key)
          preloader_AR.preload(sources, key)
        end

        children = shaped_sources.reduce({}) do |memo, source|
          memo[source] = source.public_send(key)
          memo
        end

        shaped_children = shape(children.values, subshape)

        shaped_sources.each_with_index do |source|
          data[source.uuid][key] = shape(source.public_send(key), subshape)
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
