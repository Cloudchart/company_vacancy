class EmailTemplate
  include ActiveAttr::Model

  attribute :email
  attribute :subject, default: I18n.t('user_mailer.app_invite_.subject')
  attribute :body

  validates :email, email: :true, presence: true
  validates :body, presence: true

end
