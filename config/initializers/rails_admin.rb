RailsAdmin.config do |config|
  # Main config
  #
  config.main_app_name = ['CloudChart', 'Admin']
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
          redirect_to index_path(:tag), notice: 'All selected tags are accepted'
        end
      end
    end

    member :make_unicorns do
      only ['User']
      http_methods { [:put, :patch] }
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
          # TODO: add mailer
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
              @object.destroy
            end

            redirect_to edit_path(:user, user.id), notice: 'User has been merged'
          end

        end
      end
    end

    # default
    #
    new do
      except ['Token', 'Person']
    end
    export do
      except ['Token', 'Interview']
    end
    bulk_delete
    show do
      only ['Page']
    end
    edit do
      except ['Token', 'Person']
    end
    delete do
      except ['Person']
    end
    show_in_app do
      except ['User', 'Token', 'Person', 'Tag', 'Story', 'Pinboard']
    end
    history_index do
      except ['User', 'Token', 'Person', 'Story', 'Pinboard']
    end
    history_show do
      except ['User', 'Token', 'Person', 'Story', 'Pinboard']
    end
  end

end
