class Picture < ActiveRecord::Base
  include Uuidable
  
  dragonfly_accessor :image

  has_one :block_identity, as: :identity, inverse_of: :identity
  belongs_to :owner, polymorphic: true

  enum size: [:big, :medium, :small]

  def company
    owner.try(:company)
  end

end
