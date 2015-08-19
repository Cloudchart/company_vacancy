class Paragraph < ActiveRecord::Base
  include Uuidable
  include Featurable
  include Admin::Paragraph
  
  has_one :block_identity, as: :identity, inverse_of: :identity
  belongs_to :owner, polymorphic: true

  validates :content, presence: true

  scope :plain, -> { where(owner: nil) }
  
  def as_json_for_chart
    as_json(only: [:uuid, :content])
  end

  def company
    owner.try(:company)
  end
  
end
