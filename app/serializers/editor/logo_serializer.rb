# deprecated
module Editor
  class LogoSerializer < ActiveModel::Serializer

    self.root = false

    attributes :uuid, :image_url, :thumb_url
  
    def image_url
      object.image.url
    end

    def thumb_url
      object.image.thumb.url
    end

  end
end
