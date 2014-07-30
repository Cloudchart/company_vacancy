class Token < ActiveRecord::Base
  include Uuidable

  serialize :data

  belongs_to :owner, polymorphic: true

  scope :invites, -> { where(arel_table[:name].eq(:invite).or(arel_table[:name].eq(:request_invite))) }
  
  
  
  class << self
    
    def find_by_rfc1751(param)
      find(Cloudchart::RFC1751::decode(param.upcase.gsub(/[^A-Z]+/, ' '))) rescue nil
    end

  end
  
  
  rails_admin do
    label 'Invite'
    label_plural 'Invites'

    list do
      exclude_fields :owner, :updated_at
      sort_by :created_at
      scopes { [:invites] }

      field :uuid do
        formatted_value { Cloudchart::RFC1751.encode(value) }        
        column_width 400
        filterable false
      end

      field :name do
        column_width 50
      end

      field :data do
        column_width 200
        formatted_value { value ? [value[:full_name], value[:email]].join(' – ') : nil }
        filterable false
      end

      field :created_at do
        column_width 50
      end

    end
  end
  
end
