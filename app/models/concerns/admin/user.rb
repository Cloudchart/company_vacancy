module Admin::User
  extend ActiveSupport::Concern

  included do

    rails_admin do
      object_label_method :full_name

      # List
      # 
      list do
        sort_by :created_at

        field :first_name do
          visible false
        end

        field :last_name do
          visible false
        end

        field :full_name

        field :email do
          formatted_value do 
            email = bindings[:object].email || bindings[:object].unverified_email
            bindings[:view].mail_to email, email
          end
        end

        field :subscribed?, :boolean do
          label 'Subscribed'
        end

        field :twitter do
          formatted_value do 
            if bindings[:object].twitter
              bindings[:view].link_to "@#{bindings[:object].twitter}", "https://twitter.com/#{bindings[:object].twitter}"
            else
              nil
            end
          end
        end

        field :system_roles

        field :companies do
          pretty_value { value.map { |company| bindings[:view].link_to(company.name, bindings[:view].main_app.company_path(company)) }.join(', ').html_safe }
        end

        field :created_at
        field :authorized_at
      end

      create do
        field :full_name do
          required false
        end

        field :system_roles do
          partial :system_roles
        end

        field :twitter
        field :avatar

        field :should_create_tour_tokens, :boolean do
          default_value true
        end
      end

      # Edit
      # 
      edit do
        field :full_name do
          visible do
            bindings[:object].unicorn? || bindings[:object].full_name.blank? ? true : false
          end
        end

        field :system_roles do
          partial :system_roles
        end

        field :twitter

        field :avatar do
          visible do
            bindings[:object].unicorn? ? true : false
          end
        end

        field :authorized_at do
          visible do
            bindings[:object].authorized? ? true : false
          end
        end

        field :tags
      end

      # Export
      #
      export do
        field :email do
          formatted_value do
            bindings[:object].email || bindings[:object].unverified_email
          end
        end

        field :first_name
        field :last_name
        field :full_name

        field :subscribed?, :boolean do
          label 'Subscribed'
        end

        field :confirmed do
          formatted_value do
            !!bindings[:object].email
          end
        end
      end

    end
    
  end

end
