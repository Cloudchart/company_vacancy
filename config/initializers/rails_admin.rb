RailsAdmin.config do |config|
  config.main_app_name = ['CloudChart', 'Admin']
  config.included_models = ['Company', 'Feature', 'User', 'Industry', 'Token']

  config.authenticate_with do
    authenticate_user
  end
  config.current_user_method(&:current_user)

  config.authorize_with :cancan
  config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  # https://github.com/sferik/rails_admin/wiki/Actions
  config.actions do
    dashboard # mandatory
    index # mandatory

    # custom
    # 
    collection :invite do
      link_icon 'icon-envelope'
      only ['Token']

      http_methods do 
        [:get, :post]
      end

      controller do
        proc do

          if request.post?
            @object = Token.new(params.require(:token).permit(data: [:name, :email]))
            @object.name = :invite

            if params[:token][:data][:name].blank? && params[:token][:data][:email].blank?
              @object.data = nil
            end

            if @object.save
              redirect_to index_path(:token)
            else
              render action: @action.template_name
            end
          end

        end
      end      
    end

    # default
    # 
    new do
      except ['Company', 'User', 'Token']
    end
    export do
      except ['Token']
    end
    bulk_delete
    show do
      except ['Industry', 'Token']
    end
    edit do
      except ['Company', 'Token']
    end
    delete
    show_in_app do
      except ['Token']
    end
    history_index do
      except ['Industry', 'Token']
    end
    history_show do
      except ['Industry', 'Token']
    end
  end
  
end
