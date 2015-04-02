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

  # Compamy
  #
  config.model 'Company' do
    visible false
  end

  # Feature
  #
  config.model 'Feature' do
    list do
      exclude_fields :uuid
    end

    edit do
      exclude_fields :uuid, :votes_total
    end
  end

  # Interview
  #
  config.model 'Interview' do
    list do
      exclude_fields :uuid, :email, :ref_email, :slug, :whosaid
      sort_by :created_at

      field :name do
        pretty_value { bindings[:view].mail_to bindings[:object].email, value }
      end

      field :ref_name do
        pretty_value { bindings[:view].mail_to bindings[:object].ref_email, value }
      end
    end

    edit do
      exclude_fields :uuid, :slug
    end
  end

  # Page
  #
  config.model 'Page' do
    field :title
    field :body, :wysihtml5 do
      config_options html: true
    end
  end

  # Person
  #
  config.model 'Person' do
    object_label_method :full_name

    list do
      exclude_fields :uuid, :phone, :email

      field :user do
        pretty_value { bindings[:view].mail_to value.email, value.full_name if value }
      end

      field :company do
        pretty_value { bindings[:view].link_to(value.name, bindings[:view].main_app.company_path(value)) }
      end
    end
  end

  # Pinboard
  #
  config.model 'Pinboard' do |variable|
    list do
      sort_by :title
      fields :title, :user, :created_at, :updated_at
    end

    edit do
      fields :title

      field :title do
        html_attributes do
          { autofocus: true }
        end
      end
    end
  end

  # Role
  #
  config.model 'Role' do
    visible false
    object_label_method :value
  end

  # Story
  #
  config.model 'Story' do
    list do
      sort_by :posts_stories_count
      fields :name, :company, :posts_stories_count, :created_at

      field :posts_stories_count do
        sort_reverse true
      end
    end

    edit do
      fields :name

      field :name do
        html_attributes do
          { autofocus: true }
        end
      end
    end
  end

  # Tag
  #
  config.model 'Tag' do
    list do
      sort_by :taggings_count
      fields :name, :is_acceptable, :taggings_count, :created_at

      field :taggings_count do
        sort_reverse true
      end
    end

    edit do
      fields :name, :is_acceptable

      field :name do
        html_attributes do
          { autofocus: true }
        end
      end

      field :is_acceptable do
        html_attributes do
          { checked:  bindings[:object].new_record? ? 'checked' : bindings[:object].is_acceptable }
        end

        default_value do
          '1' if bindings[:object].new_record?
        end
      end
    end

  end

  # Token
  #
  config.model 'Token' do
    label 'Invite'
    label_plural 'Invites'

    list do
      exclude_fields :owner, :updated_at
      sort_by :created_at
      scopes { [:admin_invites] }

      field :uuid do
        formatted_value { Cloudchart::RFC1751.encode(value) }
        column_width 500
        filterable false
      end

      field :name do
        column_width 50
      end

      field :data do
        # column_width 200
        formatted_value { value ? [value[:full_name], value[:email]].join(' – ') : nil }
        filterable false
      end

      field :created_at do
        column_width 50
      end
    end

  end

  # User
  #
  config.model 'User' do
    object_label_method :full_name

    list do
      include_fields :first_name, :last_name, :system_roles, :twitter, :companies, :created_at, :authorized_at
      sort_by :created_at

      field :first_name do
        label 'Full name'
        formatted_value { bindings[:view].mail_to bindings[:object].email, bindings[:object].full_name }
      end

      field :companies do
        pretty_value { value.map { |company| bindings[:view].link_to(company.name, bindings[:view].main_app.company_path(company)) }.join(', ').html_safe }
      end

      field :last_name do
        visible false
      end

    end

    edit do
      include_fields :system_roles, :twitter, :authorized_at

      field :system_roles do
        partial :system_roles
      end
    end
  end

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

    # default
    #
    new do
      except ['User', 'Token', 'Person']
    end
    export do
      except ['Token', 'Interview']
    end
    bulk_delete
    show do
      except ['User', 'Token', 'Person', 'Tag', 'Interview', 'Story', 'Pinboard']
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
