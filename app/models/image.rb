class Image < ActiveRecord::Base
  include Uuidable
  extend CarrierWave::Meta::ActiveRecord
  serialize :meta, OpenStruct  
end
