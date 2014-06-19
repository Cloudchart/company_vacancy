class Comment < ActiveRecord::Base
  include Uuidable

  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validates :content, presence: true

end
