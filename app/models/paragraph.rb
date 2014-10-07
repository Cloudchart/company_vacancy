class Paragraph < ActiveRecord::Base
  include Uuidable
  
  has_one :block_identity, as: :identity, inverse_of: :identity
  belongs_to :owner, polymorphic: true

  validates :content, presence: true
  
  def as_json_for_chart
    as_json(only: [:uuid, :content])
  end
  
end
