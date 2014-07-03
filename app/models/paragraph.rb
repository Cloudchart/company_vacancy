class Paragraph < ActiveRecord::Base
  include Uuidable

  validates :content, presence: true
  
  def as_json_for_chart
    as_json(only: [:uuid, :content])
  end
  
end
