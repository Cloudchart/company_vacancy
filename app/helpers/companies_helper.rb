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

  def calculate_social_relation_for_user(company)
    if company_owner?(company)
      'you are the owner'
    elsif current_user.companies.include?(company)
      'you work here'
    else
      friends_related_to_company = Friend.related_to_company(company.id)
      friends_working_in_company = Friend.working_in_company(company.id)

      user_company_friends_intersection = (current_user.friends & friends_working_in_company).size
      user_company_friends_of_friends_intersection = (current_user.friends & friends_related_to_company).size

      if user_company_friends_intersection > 0
        get_social_relation_weight(user_company_friends_intersection, :friends, company.people.size)
      elsif user_company_friends_of_friends_intersection > 0
        get_social_relation_weight(user_company_friends_of_friends_intersection, :friends_of_friends, company.people.size)
      else
        'none'
      end
        
    end
  end

private

  def get_social_relation_weight(intersection_size, intersection_type, company_people_size)
    company_people_size = company_people_size.to_f
    intersection_size = intersection_size.to_f

    if intersection_type == :friends
      if intersection_size / company_people_size >= 0.1
        'strong'
      else
        'significant'
      end
    elsif intersection_type == :friends_of_friends
      if intersection_size / company_people_size >= 0.5
        'good'
      elsif intersection_size / company_people_size >= 0.3
        'insignificant'
      else
        'weak'
      end
    end 
  end

end
