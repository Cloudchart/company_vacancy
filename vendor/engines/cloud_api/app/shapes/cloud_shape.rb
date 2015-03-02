class CloudShape

  include Rails.application.routes.mounted_helpers
  include Rails.application.routes.url_helpers


  cattr_reader :scopes do
    {}
  end

  cattr_reader :restricted

  cattr_reader :defaults


  class << self

    def shape(source, *shape)
      sources = wrap_sources(source, *shape).map { |source| source.to_shape }

      sources.respond_to?(:each) ? sources : sources.first
    end


    protected


    def defaults(*attributes)
      (@defaults ||= []).concat(attributes).compact.uniq
    end


    def restricted(*attributes)
      (@restricted ||= []).concat(attributes).compact.uniq
    end


    def wrap_sources(sources, *shape)

      [sources]
        .flatten
        .compact
        .group_by { |source| source.class }
        .map do |source_class, sources|
          shape_hash  = shape.extract_options!
          shape       = shape.flatten.compact.reduce({}) { |memo, key| memo[key.to_sym] = nil ; memo }.merge(shape_hash)

          shape_class     = "#{source_class.name}Shape".safe_constantize || CloudShape
          wrapped_sources = sources.map { |source| shape_class.new(source, shape) }

          case
          when source_class < ActiveRecord::Base
            shape.delete_if { |key, values| shape_class.restricted.include?(key) }

            if shape.keys.empty?
              shape.update(shape_class.defaults.reduce({}) { |memo, key| memo[key.to_sym] = nil ; memo })
            end

            shape.update({ id: nil })
          end

          preload(source_class, wrapped_sources, shape)

          wrapped_sources
        end.flatten

    end


    def preload(source_class, wrapped_sources, shape)
      sources     = wrapped_sources.map { |source| source.instance_variable_get(:@source) }
      reflectable = source_class.respond_to?(:reflect_on_association)

      shape.each do |key, shape|

        case
        when reflectable && source_class.reflect_on_association(key)
          ActiveRecord::Associations::Preloader.new.preload(sources, key)
        end

        wrapped_sources.each do |wrapped_source|
          children          = wrapped_source.public_send(key)
          wrapped_children  = wrap_sources([children], *shape)
          wrapped_children  = children.respond_to?(:each) ? wrapped_children : wrapped_children.first

          wrapped_source.define_singleton_method :"#{key}" do
            wrapped_children
          end
        end

      end
    end


  end


  def initialize(source, shape)
    @source = source
    @shape  = shape
  end


  def to_shape
    if @shape.keys.empty?
      @source
    else
      @shape.keys.reduce({}) do |memo, key|
        value       = public_send(key)
        values      = [value].flatten.compact.uniq.map(&:to_shape)
        memo[key]   = value.respond_to?(:each) ? values : values.first
        memo
      end
    end
  end


  def method_missing(method, *args, &block)
    if @source.respond_to?(method)
      @source.send(method, *args, &block)
    else
      super
    end
  end


end
