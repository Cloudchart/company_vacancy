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
      source = wrap(source, shape)
      preload(source, shape)
      source.as_json
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


    def shape_for(source)
      if source.class < ActiveRecord::Base
        "#{source.class}Shape".safe_constantize || CloudShape
      else
        nil
      end
    end


    def fields_for(shape_class, shape)
      fields = if shape
        shape.fetch(:fields, {}).keys
      else
        []
      end

      fields = fields - shape_class.restricted
      fields = fields | shape_class.defaults | [:id]

      fields
    end


    def wrap(source, shape)
      if source.respond_to?(:each)
        source = Array.wrap(source).flatten.compact
        shape_class = shape_for(source.first)

        if shape_class
          shape_fields = fields_for(shape_class, shape)
          source.map { |s| shape_class.new(s, shape_fields) }
        else
          source
        end

      else
        shape_class = shape_for(source)

        if shape_class
          shape_fields = fields_for(shape_class, shape)
          shape_class.new(source, shape_fields)
        else
          source
        end

      end
    end


    def preload(source, shape)
      group_sources(Array.wrap(source).flatten).each do |source_class, source_group|
        preload_one(source_group, shape)
      end
    end


    def preload_one(sources, shape)
      fields        = sources.first.instance_variable_get(:@fields)
      origins       = sources.map { |source| source.instance_variable_get(:@source) }
      origin_class  = origins.first.class

      fields.each do |field|

        case
        when current_scope = scope(field)
          current_scope.call(sources)
        when association = origin_class.reflect_on_association(field)
          ActiveRecord::Associations::Preloader.new.preload(origins, field)
        else
          next
        end

        child_shape = shape.fetch(:fields, {}).fetch(field, {})

        children = sources.map do |source|
          value = wrap(source.public_send(field), child_shape)
          source.define_singleton_method(field) { value }
          source.public_send(field)
        end

        preload(children, child_shape)

      end
    end


    def group_sources(sources)
      result = {}

      sources.each do |source|
        next unless source
        (result[source.instance_variable_get(:@source).class] ||= []) << source
      end

      result
    end


  end


  def initialize(source, fields)
    @source = source
    @fields = fields
  end


  def as_json
    @fields.reduce({}) do |memo, field|
      memo[field] = public_send(field).as_json
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
