module CompaniesHelper
  
  def display_logo(company)
    if company.logo.present?
      image = if company.logo.image.thumb.present?
        company.logo.image.thumb.url
      else
        company.logo.image.url
      end
      
      image_tag image
    end
  end

  # def is_subscribed_to_company?(company)
  #   (current_user.people & company.people).first.try(:subscribed_to_company_at).present?    
  # end

end
