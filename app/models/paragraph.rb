class Paragraph < ActiveRecord::Base
  include Uuidable

  validates :content, presence: true

end
