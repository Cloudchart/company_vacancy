class Landing < ActiveRecord::Base
  include Uuidable
  include FriendlyId

  dragonfly_accessor :image

  friendly_id :twitter_with_random_hex, use: :slugged

  belongs_to :user
  belongs_to :author, class_name: 'User'

  delegate :twitter, to: :user, allow_nil: true

  validates :user, :author, :body, presence: true

  def twitter_with_random_hex
    "#{twitter}-#{SecureRandom.hex(2)}"
  end

  def should_generate_new_friendly_id?
    user_id_changed?
  end

end
