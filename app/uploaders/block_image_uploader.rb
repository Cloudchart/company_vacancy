# encoding: utf-8

class BlockImageUploader < ApplicationUploader
  # Process files as they are uploaded:
  # process resize_to_limit: [1500, 1125]

  process :crop_and_resize
  process :store_meta

  def crop_and_resize
    manipulate! do |image|
      # get source dimentions and set desired aspect ratio 
      width, height = image[:dimensions]
      src_aspect = width.to_f / height.to_f
      dst_aspect = 4.to_f / 3.to_f

      # crop image if source aspect less than 4/3
      if src_aspect < dst_aspect
        cropped_height = (width.to_f / dst_aspect).round
        image.crop "#{width}x#{cropped_height}+0+0"
      end

      # resize image if width > 1500px
      image.resize '1500>'

      image
    end
  end

  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #  process resize_to_fit: [200, 200]
  #  process :store_meta
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
