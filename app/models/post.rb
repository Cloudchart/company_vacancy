class Post < ActiveRecord::Base
  include Uuidable
  include Blockable
  include Taggable

  belongs_to :owner, polymorphic: true

  has_one :visibility, as: :owner, dependent: :destroy

  def company
    owner if owner_type == 'Company'
  end

end
