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
      stored_path = session.delete(session_store_key)
      stored_path = path if stored_path == main_app.root_path or stored_path == main_app.root_url
      redirect_to stored_path || path
    end
    
    def session_store_key
      :cloud_profile_return_to
    end

    def previous_path
      if current_user.try(:is_admin?) && current_user.email == ENV['DEFAULT_ADMIN_EMAIL']
        rails_admin.dashboard_path
      else
        session[:previous_path] || main_app.root_path
      end
    end

  end
end
