module CloudProfile
  class Email < ActiveRecord::Base
    include Uuidable
    
    before_destroy :check_user_emails, unless: :marked_for_destruction?

    belongs_to :user
    has_many :tokens, as: :owner, dependent: :destroy

    validates :address, presence: true, uniqueness: true, format: { with: /.+@.+\..+/i }
    
    def active?
      persisted? && !activation_token.present?
    end
    
    def activation_token
      @activation_token ||= tokens.find { |token| token.name == 'email-activation' }
    end
    
    def generate_activation_token
      activation_token || begin
        tokens << Token.new(name: 'email-activation')
      end
    end
    
  private
    
    def check_user_emails
      emails = user.emails.includes(:tokens)
      if active?
        emails.select(&:active?)
      else
        emails
      end.size > 1
    end

  end
end
