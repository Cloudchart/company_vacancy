class BlockImage < ActiveRecord::Base
  extend CarrierWave::Meta::ActiveRecord
  include Uuidable
  include Imageable
  
  has_one :block_identity, as: :identity, inverse_of: :identity

  serialize :meta, OpenStruct

  validates :image, presence: true

end
