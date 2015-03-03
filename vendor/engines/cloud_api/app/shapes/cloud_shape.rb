class CloudShape

  include Rails.application.routes.mounted_helpers
  include Rails.application.routes.url_helpers


  cattr_reader :scopes do
    {}
  end

  cattr_reader :restricted

  cattr_reader :defaults


  class << self

    def shape(source, shape)
      shaped_sources = wrap([source].flatten.compact.uniq, shape)

      fetch(shaped_sources)

      shaped_sources = shaped_sources.map(&:to_shape)

      source.respond_to?(:each) ? shaped_sources : shaped_sources.first
    end


    protected


    def defaults(*attributes)
      (@defaults ||= []).concat(attributes).compact.uniq
    end


    def restricted(*attributes)
      (@restricted ||= []).concat(attributes).compact.uniq
    end


    def scope(name, &block)
      if block_given?
        define_method :"#{name}" do
          instance_variable_get(:"@#{name}")
        end

        define_method :"#{name}=" do |value|
          instance_variable_set(:"@#{name}", value)
        end

        scopes[name.to_sym] = block
      else
        scopes[name.to_sym]
      end
    end



    def wrap(sources, shape)
      sources
        .group_by { |source| source.class }
        .map do |source_class, sources|

          shape_class   = "#{source_class.name}Shape".safe_constantize || CloudShape
          shape_sources = sources.map { |source| shape_class.new(source, shape) }

        end
        .flatten
    end


    def preload(shaped_sources)
      shape         = shaped_sources.first.instance_variable_get(:@shape)
      sources       = shaped_sources.map { |shaped_source| shaped_source.instance_variable_get(:@source) }
      source_class  = sources.first.class

      shape.fetch(:fields, {}).keys.each do |field|

        case

        when source_class.try(:reflect_on_association, field)
          ActiveRecord::Associations::Preloader.new.preload(sources, field)

        end


        shaped_children = shaped_sources.map do |shaped_source|
          value   = shaped_source.public_send(field)
          values  = wrap([value].flatten.compact.uniq, shape[:fields][field])
          value   = value.respond_to?(:each) ? values : values.first

          shaped_source.define_singleton_method(field.to_sym) { value }

          values
        end

        #fetch(shaped_children)

      end if shape

    end


    def fetch(shaped_sources)
      shaped_sources
        .flatten
        .compact
        .group_by do |source|
          source.instance_variable_get(:@source).class
        end
        .each do |source_class, sources|
          preload(sources)
        end
    end


  end


  def initialize(source, shape = {})
    @source = source
    @shape  = shape
  end


  def to_shape
    unless @shape
      @source
    else
      @shape[:fields].keys.reduce({}) do |memo, key|
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
