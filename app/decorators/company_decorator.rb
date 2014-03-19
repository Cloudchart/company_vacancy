class CompanyDecorator < ApplicationDecorator
  decorates :company

  def logo
    image_tag company.try(:logo).try(:image_url)
  end

end
