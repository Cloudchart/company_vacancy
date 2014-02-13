class Paragraph < ActiveRecord::Base
  include Uuidable
  include Blockables

  validates :content, presence: true
  
end
