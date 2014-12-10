class Visibility < ActiveRecord::Base
  include Uuidable

  belongs_to :owner, polymorphic: true

  validates :value, presence: true
  validates :value, inclusion: { in: Post::VISIBILITY_WHITELIST.map(&:to_s) }, if: -> { owner_type == 'Post' }

end
