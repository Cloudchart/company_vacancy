class Post < ActiveRecord::Base
  include Uuidable
  include Blockable

  belongs_to :owner, polymorphic: true

  # validates :title, presence: true, on: :update

  def company
    owner if owner_type == 'Company'
  end

end
