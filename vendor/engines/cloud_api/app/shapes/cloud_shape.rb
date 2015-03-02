class CloudShape

  include Rails.application.routes.mounted_helpers
  include Rails.application.routes.url_helpers


  cattr_reader :scopes do
    {}
  end


  class << self

    def shape(source, *shape)
      sources = [source].flatten.compact.uniq

      sources = render(sources, shape)

      sources.respond_to?(:each) ? sources : sources.first
    end


    protected


    def render(sources, shape)

      sources
        .group_by { |source| source.class }
        .map do |source_class, sources|
          shape_class = "#{source_class.name}Shape".constantize rescue CloudShape
          sources     = sources.map { |source| shape_class.new(sources, shape) }

          

        end.flatten

    end


  end


  def initialize(source, shape)
    @source = source
    @shape  = shape
  end


  def method_missing(method, *args, &block)
    if @source.respond_to?(method)
      @source.send(method, *args, &block)
    else
      super
    end
  end


end
