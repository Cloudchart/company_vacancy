module MetaTagsHelper
  def og_image_url(url = nil)
    url.present? ? url : image_url('logo-square.png')
  end
end
