module Admin::Token
  extend ActiveSupport::Concern

  included do

    rails_admin do
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
          formatted_value { value ? [value[:full_name], value[:email]].join(' – ') : nil }
          filterable false
        end

        field :created_at do
          column_width 50
        end
      end
    end

  end
  
end
