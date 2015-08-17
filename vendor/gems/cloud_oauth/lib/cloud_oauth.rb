module CloudOAuth
  
  autoload :Facebook, 'cloud_oauth/facebook'
  autoload :Linkedin, 'cloud_oauth/linkedin'
  autoload :Twitter, 'cloud_oauth/twitter'

  mattr_reader :providers
  @@providers = {}
  
  def self.configure
    yield self if block_given?
  end
  
  def self.[](name)
    public_send(name)
  end
  
  def self.method_missing(method)
    const_get(method.to_s.classify).tap do |provider|
      if block_given?
        yield provider.config
        @@providers.delete(method)
      end
      @@providers[method] ||= provider.new
    end
    @@providers[method]
  rescue NameError
    super
  end

end
