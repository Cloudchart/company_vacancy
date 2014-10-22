class Event < ActiveRecord::Base
  include Uuidable
  include Blockable
  include Trackable

  belongs_to :company
  belongs_to :author, class_name: 'User'
  has_one :token, as: :owner, dependent: :destroy
  # has_paper_trail

  validates :name, presence: true
  validates :url, url: true, allow_blank: true

  def build_objects
    build_token(name: :verification) if url.present?
    # blocks.build(position: 0, identity_type: 'Paragraph', is_locked: true)
  end

end
