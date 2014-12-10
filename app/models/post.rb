class Post < ActiveRecord::Base
  include Uuidable
  include Blockable
  include Taggable

  belongs_to :owner, polymorphic: true

  has_many :visibilities, as: :owner, dependent: :destroy

  def company
    owner if owner_type == 'Company'
  end

  def visibility
    visibilities.first
  end

end
