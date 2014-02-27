class BlockImage < ActiveRecord::Base
  extend CarrierWave::Meta::ActiveRecord
  include Uuidable
  include Imageable
  
  serialize :meta, OpenStruct

  validates :image, presence: true

end
