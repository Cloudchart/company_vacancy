module Imageable
  extend ActiveSupport::Concern

  included do
    has_paper_trail

    uploader = "#{name}Uploader".constantize
    versions = uploader.versions.keys.inject([]) { |array, version| array << :"image_#{version}" }

    mount_uploader :image, uploader
    carrierwave_meta_composed :meta, :image, *versions
  end

end
