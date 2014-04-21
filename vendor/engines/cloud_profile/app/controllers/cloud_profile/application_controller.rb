module CloudProfile
  class ApplicationController < ::ApplicationController
   

  protected
  
    def store_return_path
      session[session_store_key] = params[:return_to] || request.env['HTTP_REFERER']
    end
    
    def return_path_stored?
      session[session_store_key].present?
    end
  
    def redirect_to_stored_path_or_root
      redirect_to_stored_path_or
    end
    
    def redirect_to_stored_path_or(path = main_app.root_path)
      redirect_to session.delete(session_store_key) || path
    end
    
    def session_store_key
      :cloud_profile_return_to
    end
    
    def require_authenticated_user!
      redirect_to main_app.root_path unless user_authenticated?
    end
    
    def require_unauthenticated_user!
      redirect_to main_app.root_path if user_authenticated?
    end

  end
end
