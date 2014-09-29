RailsAdmin.config do |config|
  config.main_app_name = ['CloudChart', 'Admin']
  config.included_models = ['Company', 'Feature', 'User', 'Token', 'Page', 'Person', 'Tag']

  config.authenticate_with do
    authenticate_user
  end
  config.current_user_method(&:current_user)

  config.authorize_with :cancan
  config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  config.model 'Company' do
    visible false
  end  

  # https://github.com/sferik/rails_admin/wiki/Actions
  config.actions do
    dashboard # mandatory
    index # mandatory

    # custom
    # 
    member :make_acceptable do
      only ['Tag']
      http_methods { [:put, :patch] }
      register_instance_option :bulkable? do
        true
      end
      controller do
        proc do
          Tag.find(params[:bulk_ids]).each { |tag| tag.update(is_acceptable: true) }
          redirect_to index_path(:tag), notice: 'All selected tags have become acceptable'
        end
      end
    end

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

      register_instance_option :pjax? do 
        false
      end

      register_instance_option :visible? do 
        bindings[:object].try(:name) == 'request_invite'
      end

      controller do
        proc do
          unless @object.name == 'invite'
            @object.update(name: :invite)
            UserMailer.app_invite(@object).deliver if @object.data.present?
          end
          
          redirect_to index_path(:token), notice: 'Request has been accepted'
        end
      end
    end

    # default
    # 
    new do
      except ['User', 'Token', 'Person']
    end
    export do
      except ['Token']
    end
    bulk_delete
    show do
      except ['User', 'Token', 'Person', 'Tag']
    end
    edit do
      except ['User', 'Token']
    end
    delete do
      except ['Person']
    end
    show_in_app do
      except ['User', 'Token', 'Person', 'Tag']
    end
    history_index do
      except ['User', 'Token', 'Person']
    end
    history_show do
      except ['User', 'Token', 'Person']
    end
  end
  
end
