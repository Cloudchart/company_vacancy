class Pin < ActiveRecord::Base
  include Uuidable

  belongs_to  :user
  belongs_to  :parent,    class_name: Pin
  belongs_to  :pinboard
  belongs_to  :pinnable,  polymorphic: true

  belongs_to  :post, foreign_key: :pinnable_id, foreign_type: Post

  has_many    :children,  class_name: Pin, foreign_key: :parent_id


  validates_presence_of :content, if: :should_validate_content_presence?


  def should_validate_content_presence?
    @update_by.present? && user_id != @update_by.uuid
  end


  def update_by!(update_by)
    @update_by = update_by
  end


  def destroy
    Pin.transaction do
      update(pinboard_id: nil, pinnable_id: nil, pinnable_type: nil)
      super if children.size == 0
      parent.destroy if parent.present? and parent.pinnable.blank?
    end
  end

end
