module Admin::Person
  extend ActiveSupport::Concern

  included do

    rails_admin do
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

  end
  
end
