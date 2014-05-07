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

  def subscribed_to_company?(company)
    current_user.subscriptions.map(&:subscribable_id).include?(company.id)
  end

  def company_owner?(company)
    (current_user.people & company.people).first.try(:is_company_owner?)
  end

end
