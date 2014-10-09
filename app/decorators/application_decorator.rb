class ApplicationDecorator

  def initialize(object)
    @object = object
  end

  attr_reader :object

private

  def self.decorates(name)
    define_method(name) do
      @object
    end
  end

  def to_param
    @object.to_param
  end

  def method_missing(method_name, *args, &block)
    if @object.respond_to?(method_name)
      @object.send(method_name, *args, &block)
    elsif ActionController::Base.helpers.respond_to?(method_name)
      ActionController::Base.helpers.send(method_name, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    @object.respond_to?(method_name, include_private) ||
    ActionController::Base.helpers.respond_to?(method_name, include_private) ||
    super
  end

end
