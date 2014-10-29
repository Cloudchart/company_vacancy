class Post < ActiveRecord::Base
  include Uuidable

  dragonfly_accessor :cover

  belongs_to :owner, polymorphic: true

  validates :title, presence: true

end
