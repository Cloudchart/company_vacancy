class Post < ActiveRecord::Base
  include Uuidable
  include Blockable

  dragonfly_accessor :cover

  belongs_to :owner, polymorphic: true

  validates :title, presence: true

  def company
    owner if owner_type == 'Company'
  end

end
