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
      only ['Token']
      link_icon 'icon-envelope'
      http_methods { [:get, :post] }

      controller do
        proc do

          if request.post?
            full_name = params[:full_name]
            email = params[:email]

            if full_name.blank? && email.present? || full_name.present? && email.blank?
              redirect_to :back, alert: 'Full name and email must be filled both or left blank'
            elsif email.present? && CloudProfile::Email.find_by(address: email)
              redirect_to :back, alert: 'We already have user with this email address in database'
            else
              @object = Token.new(
                name: :invite,
                data: { full_name: full_name, email: email }
              )
              @object.data = nil if full_name.blank? && email.blank?
              @object.save

              UserMailer.app_invite(@object).deliver if @object.data.present?

              redirect_to index_path(:token), notice: 'Invite has been created'
            end
            
          end

        end
      end
    end

    member :accept_invite do
      only ['Token']
      link_icon 'icon-ok'
      visible { bindings[:object].name == 'request_invite' }

      controller do
        proc do
          @object.update(name: :invite)
          UserMailer.app_invite(@object).deliver if @object.data.present?
          redirect_to index_path(:token), notice: 'Request has been accepted'
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
