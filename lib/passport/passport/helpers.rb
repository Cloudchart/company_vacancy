module Passport::Helpers
  module Controller
    extend ActiveSupport::Concern
    
    included do
      helper_method :warden
    end
    
    def self.define_helpers(model)
      name = model.to_sym
      
      class_eval <<-HELPERS
        
        def authenticate_#{name}!(options = {})
          options[:scope] = :#{name}
          warden.authenticate!(options)
        end
        
        def #{name}_signed_in?
          !!current_#{name}
        end
        
        def current_#{name}
          @current_#{name} ||= warden.authenticate(scope: :#{name})
        end
        
      HELPERS
      
      ActiveSupport.on_load(:action_controller) do
        helper_method "current_#{name}", "#{name}_signed_in?"
      end

    end
    
    def warden
      request.env['warden']
    end    
    
  end
end
