class CloudShape

  include Rails.application.routes.mounted_helpers
  include Rails.application.routes.url_helpers


  cattr_reader :scopes do
    {}
  end


  class << self

    def shape(source, *shape)
      sources = wrap_sources(source, *shape).map { |source| source.to_shape }

      sources.respond_to?(:each) ? sources : sources.first
    end


    protected


    def wrap_sources(sources, *shape)

      [sources]
        .flatten
        .compact
        .group_by { |source| source.class }
        .map do |source_class, sources|
          shape_hash  = shape.extract_options!
          shape       = shape.flatten.compact.reduce({}) { |memo, key| memo[key.to_sym] = nil ; memo }.merge(shape_hash)

          shape_class     = "#{source_class.name}Shape".constantize rescue CloudShape
          wrapped_sources = sources.map { |source| shape_class.new(source, shape) }

          preload(source_class, wrapped_sources, shape) if shape

          wrapped_sources
        end.flatten

    end


    def preload(source_class, wrapped_sources, shape)
      shape.each do |key, shape|

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


  def initialize(source, *shape)
    shape_options = shape.extract_options!
    shape         = shape.flatten.compact.reduce({}) { |memo, key| memo[key] = nil ; memo }.merge(shape_options)

    @source = source
    @shape  = shape
  end


  def to_shape
    @shape.keys.reduce({}) do |memo, key|
      value       = public_send(key)
      values      = [value].flatten.compact.uniq.map(&:to_shape)
      memo[key]   = value.respond_to?(:each) ? values : values.first
      memo
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
