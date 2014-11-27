class Post < ActiveRecord::Base
  include Uuidable
  include Blockable
  include Taggable

  belongs_to :owner, polymorphic: true

  def company
    owner if owner_type == 'Company'
  end

end
