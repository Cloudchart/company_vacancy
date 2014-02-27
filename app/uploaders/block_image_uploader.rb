# encoding: utf-8

class BlockImageUploader < BaseUploader
  # Process files as they are uploaded:
  # process resize_to_limit: [1500, 1500]

  process :magnify
  process :store_meta

  def magnify
    manipulate! do |image|
      image.scale "200%"
      image
    end
  end

  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  #version :thumb do
  #  process resize_to_fit: [200, 200]
  #  process :store_meta
  #end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
