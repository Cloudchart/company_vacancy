class Report
  include ActiveAttr::Model

  attribute :url
  attribute :reason

  validates :url, app_url: :true, presence: true
  validates :reason, presence: true

end
