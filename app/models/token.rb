class Token < ActiveRecord::Base
  include Uuidable
  include Admin::Token

  serialize :data

  belongs_to :owner, polymorphic: true, inverse_of: :tokens
  belongs_to :target, polymorphic: true


  scope :admin_invites, -> { where(arel_table[:name].eq(:invite).or(arel_table[:name].eq(:request_invite)).and(arel_table[:owner_id].eq(nil))) }

  validates :name, presence: true

  validates_with InviteValidator, if: :should_validate_as_invite?, on: :create

  class << self

    def find_by_rfc1751(param)
      find(Cloudchart::RFC1751::decode(param.upcase.gsub(/[^A-Z]+/, ' '))) rescue nil
    end

    def find_or_create_token_by!(attributes)
      find_by(name: attributes[:name], owner: attributes[:owner]) || create!(attributes)
    end

    def find(*args)
      find_by_rfc1751(args.first) || super
    end

    def select_by_user(user_id, user_emails)
      self.select do |token|
        if token.data[:user_id].present?
          token.data[:user_id] == user_id
        else
          user_emails.include?(token.data[:email])
        end
      end
    end

  end

  def data=(data_attribute)
    write_attribute(:data, data_attribute.try(:to_hash).try(:symbolize_keys))
  end

private

  def should_validate_as_invite?
    owner_type =~ /Company|Pinboard/ && name.to_sym == :invite
  end

end
