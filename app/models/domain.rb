class Domain < ActiveRecord::Base
  include Uuidable
  include Admin::Domain

  before_save :remove_protocol_from_name

  enum status: [:pending, :allowed, :forbidden]
  enum diffbot_api: [:analyze, :disabled, :article, :image, :product]

  validates :name, domain: true, presence: true, uniqueness: true

private

  def remove_protocol_from_name
    self.name = name.gsub(/https?:\/\//, '')
  end

end
