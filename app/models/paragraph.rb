class Paragraph < ActiveRecord::Base
  include Uuidable

  # has_paper_trail

  validates :content, presence: true
  
end
