class Company < ActiveRecord::Base
  include Extensions::UUID

  mount_uploader :logo, LogoUploader

  has_many :block_items, as: :ownerable, dependent: :destroy

  validates :name, presence: true
end
