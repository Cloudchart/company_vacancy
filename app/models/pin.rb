class Pin < ActiveRecord::Base
  include Uuidable
  include Trackable
  include Featurable
  include Admin::Pin

  belongs_to :user
  belongs_to :parent, class_name: 'Pin'
  belongs_to :pinboard
  belongs_to :pinnable, polymorphic: true
  belongs_to :post, foreign_key: :pinnable_id

  has_many :children, class_name: 'Pin', foreign_key: :parent_id

  validates :content, presence: true, if: :should_validate_content_presence?

  scope :insights, -> { where.not(content: '').where.not(content: nil) }

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
