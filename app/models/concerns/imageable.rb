module Imageable
  extend ActiveSupport::Concern

  included do
    extend CarrierWave::Meta::ActiveRecord
    self.table_name = :images
    serialize :meta, OpenStruct

    uploader = "#{name}Uploader".constantize
    versions = uploader.versions.keys.inject([]) { |array, version| array << :"image_#{version}" }

    mount_uploader :image, uploader
    carrierwave_meta_composed :meta, :image, *versions
  end

end