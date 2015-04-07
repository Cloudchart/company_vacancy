module Admin::Interview
  extend ActiveSupport::Concern

  included do

    rails_admin do
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

  end
  
end
