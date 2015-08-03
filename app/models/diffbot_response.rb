class DiffbotResponse < ActiveRecord::Base
  include Uuidable

  serialize :body
  serialize :data

  has_many :diffbot_response_owners, dependent: :destroy

  validates :api, presence: true
  validates :resolved_url, url: true, uniqueness: { scope: :api }

end
