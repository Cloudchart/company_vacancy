class Logo < Image
  include Imageable  
  
  validates :image, file_size: { maximum: 1.megabytes.to_i }
  validate :validate_minimum_image_size

  def validate_minimum_image_size
    if image.width < 100 && image.content_type != 'image/svg+xml'
      errors.add :image, I18n.t('errors.messages.width_too_small')
    end
  end

end
