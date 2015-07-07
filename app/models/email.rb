class Email < ActiveRecord::Base
  include Uuidable

  self.table_name = "cloud_profile_emails"
  
  before_destroy :check_user_emails, unless: :marked_for_destruction?

  belongs_to :user
  has_many :tokens, as: :owner, dependent: :destroy

  validates :address, presence: true, uniqueness: true, format: { with: /.+@.+\..+/i }
  
private
  
  def check_user_emails
    user.emails.size > 1
  end

end
