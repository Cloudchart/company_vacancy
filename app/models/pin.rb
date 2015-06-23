class Pin < ActiveRecord::Base
  include Uuidable
  include Trackable
  include Featurable
  include Previewable
  include Admin::Pin

  nilify_blanks only: [:content]

  belongs_to :user
  belongs_to :parent, class_name: 'Pin', counter_cache: true
  belongs_to :pinboard
  belongs_to :pinnable, polymorphic: true
  belongs_to :post, foreign_key: :pinnable_id
  belongs_to :author, class_name: 'User'

  has_many :children, class_name: 'Pin', foreign_key: :parent_id
  has_many :features, inverse_of: :insight

  validates :content, presence: true, if: :should_validate_content_presence?

  scope :insights, -> { where(parent: nil).where.not(content: nil, pinnable: nil) }
  scope :limbo, -> { where(parent: nil, pinnable: nil).where.not(content: nil, author: nil) }


  before_save :skip_generate_preview!, unless: :insight?


  def insight?
    parent_id.blank? && content.present? && pinnable_id.present?
  end


  def content
    is_suggestion ? parent.content : read_attribute(:content)
  end


  def should_validate_content_presence?
    @update_by.present? && user_id != @update_by.uuid && !is_suggestion
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
