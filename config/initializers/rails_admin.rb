RailsAdmin.config do |config|
  # Main config
  #
  config.main_app_name = [ENV['SITE_NAME'], 'Admin']
  config.included_models = Cloudchart::RAILS_ADMIN_INCLUDED_MODELS

  config.authenticate_with do
    authenticate_user
  end
  config.current_user_method(&:current_user)

  config.authorize_with :cancan, AdminAbility
  config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  # Actions
  #
  config.actions do

    # default
    #
    dashboard # mandatory
    index # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
    history_index
    history_show

    # custom
    #
    member :make_featured do
      only Feature::FEATURABLE_TYPES
      link_icon 'icon-bookmark'
      http_methods { [:post, :get] }
      register_instance_option :bulkable? do
        true
      end
      controller do
        proc do
          if request.get?
            @object.update(is_featured: '1')
            redirect_to index_path(params[:model_name]), notice: 'Record has been featured'
          elsif request.post?
            params[:model_name].classify.constantize.find(params[:bulk_ids]).each { |object| object.update(is_featured: '1') }
            redirect_to index_path(params[:model_name]), notice: 'All records has been featured'
          end
        end
      end
    end

    member :make_acceptable do
      only ['Tag']
      http_methods { [:post] }
      register_instance_option :bulkable? do
        true
      end
      controller do
        proc do
          Tag.find(params[:bulk_ids]).each { |tag| tag.update(is_acceptable: true) }
          redirect_to index_path(:tag), notice: 'All selected tags are accepted'
        end
      end
    end

    member :make_unicorns do
      only ['User']
      http_methods { [:post] }
      register_instance_option :bulkable? do
        true
      end
      controller do
        proc do
          User.find(params[:bulk_ids]).each { |user| user.update(system_role_ids: user.system_roles.map(&:value) + ['unicorn']) }
          redirect_to index_path(:user), notice: 'All selected users became unicorns'
        end
      end
    end

    member :make_active do
      only ['Feature']
      http_methods { [:post] }
      register_instance_option :bulkable? do
        true
      end
      controller do
        proc do
          Feature.find(params[:bulk_ids]).each { |feature| feature.update(is_active: true) }
          redirect_to index_path(:feature), notice: 'All selected features became active'
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
            elsif email.present? && Email.find_by(address: email)
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

    member :authorize do
      only ['User']
      link_icon 'icon-ok'

      controller do
        proc do
          @object.update(authorized_at: Time.now)
          UserMailer.app_invite_(@object).deliver
          redirect_to index_path(:user), notice: 'User has been authorized'
        end
      end
    end

    member :merge do
      only ['User']
      link_icon 'icon-user'
      http_methods { [:get, :post] }

      controller do
        proc do

          if request.get?
            @users = User.available_for_merge(@object)
          elsif request.post?
            user = User.find(params[:user_id])

            User.transaction do
              [:full_name, :twitter, :avatar, :occupation, :company].each do |attribute|
                user.send(:"#{attribute}=", @object.send(attribute))
              end
              user.authorized_at = Time.now
              @object.emails.first.update(user: user) if @object.email
              @object.update(twitter: nil)

              user.save!
              UserMailer.app_invite_(user).deliver
              @object.destroy
            end

            redirect_to edit_path(:user, user.id), notice: 'User has been merged'
          end

        end
      end
    end

    member :approve do
      only ['Pin']
      link_icon 'icon-ok'
      http_methods { [:post, :get] }

      register_instance_option :bulkable? do
        true
      end

      controller do
        proc do
          if request.get?
            @object.update(is_approved: true)
            redirect_to index_path(:pin), notice: 'Insight has been approved'
          elsif request.post?
            Pin.find(params[:bulk_ids]).each { |pin| pin.update(is_approved: true) }
            redirect_to index_path(:pin), notice: 'All selected insights approved'
          end
        end
      end
    end

  end

end
