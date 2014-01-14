module Passport
  mattr_reader :models
  @@models = {}

  mattr_reader :helpers
  @@helpers = []
  @@helpers << Passport::Helpers::Controller

  mattr_accessor :warden_config
  @@warden_config = nil

  def self.configure(&block)
    yield self if block_given?
  end

  def self.model(name, options={})
    models[name.to_sym] = Passport::Model.new(name.to_sym, options)
    helpers.each { |h| h.define_helpers(name.to_sym) }
  end

  def self.configure_warden!
    @@warden_configured ||= begin

      warden_config.failure_app = Passport::FailureApp
      warden_config.intercept_401 = false
      
      models.each_value do |model|
        warden_config.scope_defaults model.name, strategies: model.strategies
        
        warden_config.serialize_into_session(model.name) do |user|
          model.to.serialize_into_session(user)
        end

        warden_config.serialize_from_session(model.name) do |id|
          model.to.serialize_from_session(id)
        end
      end

      true 
    end
  end

end
