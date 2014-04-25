# encoding: utf-8

class LogoUploader < ApplicationUploader
  # Process files as they are uploaded:
  # process resize_to_fit: [100, 100]
  # process :store_meta

  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :thumb, if: :is_image? do
    process resize_to_fit: [100, 100]
    process :store_meta
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg png svg)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  # for image size validation
  # fetching dimensions in uploader, validating it in model
  # https://gist.github.com/lulalala/6172653
  attr_reader :width, :height, :content_type
  before :cache, :capture_size
  def capture_size(file)
    if version_name.blank? # Only do this once, to the original version
      @width, @height = `identify -format "%wx %h" #{file.path}`.split(/x/).map{|dim| dim.to_i }
      @content_type = file.content_type
    end
  end

private

  def is_image?(image)
    image.content_type != 'image/svg+xml'
  end

end
