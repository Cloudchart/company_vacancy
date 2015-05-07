class EmailTemplate
  include ActiveAttr::Model

  attribute :email
  attribute :subject
  attribute :body

  validates :email, email: :true, presence: true
  validates :subject, presence: true

end
