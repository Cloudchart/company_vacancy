class Image < ActiveRecord::Base
  include Uuidable
  extend CarrierWave::Meta::ActiveRecord
  serialize :meta, OpenStruct

  belongs_to :owner, polymorphic: true

end
