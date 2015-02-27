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
        .group_by { |source| source.class }
        .map do |key, sources|
          shaper = "#{key.underscope}_shape".classify.constantize rescue self
          sources.each { |source| wrap(source, shaper, shape) }

          shaper.process(key, sources, shape)
        end
        .flatten

      shapes = sources.map { |source| source.to_shape! }

      source.respond_to?(:each) ? shapes : shapes.first
    end

  protected

    def wrap(source, shaper, shape)
      shape_instance = shaper.new(source, shape)

      source.define_singleton_method :to_shape! do
        shape_instance.to_shape!
      end
    end

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


    def process(klass, sources, shape)
      shape.each do |key, subshape|

        if current_scope = scope(key)
          current_scope.call(sources, subshape)
        elsif klass.respond_to?(:reflect_on_association) && klass.reflect_on_association(key)
          preloader_AR.preload(sources, key)
        end

        shape(sources.map { |source| source.public_send(key) }, subshape)

      end

      sources
    end

  end



  def initialize(source, shape)
    @source = source
    @shape  = shape
  end


  def to_shape!
    case

    when @source.is_a?(ActiveRecord::Base)
      @shape.keys.concat([:id]).reduce({}) do |memo, pair|
        key, shape  = pair
        child       = public_send(key)
        children    = [child].flatten.compact.uniq.map { |child| child.to_shape! rescue child }
        memo[key]   = child.respond_to?(:each) ? children : children.first
        memo
      end

    else
      @source
    end
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
