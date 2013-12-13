class Text < ActiveRecord::Base
  include Uuidable
  include Blockable

  validates :content, presence: true
end
