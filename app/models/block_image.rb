class BlockImage < ActiveRecord::Base
  include Uuidable
  extend CarrierWave::Meta::ActiveRecord
  include Imageable
  
  serialize :meta, OpenStruct

  validates :image, presence: true

end
