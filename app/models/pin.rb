class Pin < ActiveRecord::Base
  include Uuidable
  include Trackable
  include Featurable
  include Admin::Pin

  nilify_blanks only: [:content]

  belongs_to :user
  belongs_to :parent, class_name: 'Pin', counter_cache: true
  belongs_to :pinboard
  belongs_to :pinnable, polymorphic: true
  belongs_to :post, foreign_key: :pinnable_id

  has_many :children, class_name: 'Pin', foreign_key: :parent_id
  has_many :features, inverse_of: :insight

  validates :content, presence: true, if: :should_validate_content_presence?

  scope :insights, -> { where(parent_id: nil).where.not(content: nil, pinnable_id: nil) }

  def should_validate_content_presence?
    @update_by.present? && user_id != @update_by.uuid
  end

  def update_by!(update_by)
    @update_by = update_by
  end

  def destroy
    Pin.transaction do
      update(pinboard: nil, pinnable: nil)
      parent.destroy if parent && parent.pinnable.blank?
      activities.destroy_all
      super if children.empty?
    end
  end

end
