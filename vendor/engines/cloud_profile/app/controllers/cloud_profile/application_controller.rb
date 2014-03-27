module CloudProfile
  class ApplicationController < ::ApplicationController
    
  protected
  
    def store_return_path
      session[session_store_key] = params[:return_to] || request.referer
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
    
    def session_store_redirect_key
      :cloud_profile_return_to
    end
    
  end
end
