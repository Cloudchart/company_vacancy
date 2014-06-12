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

  def calculate_social_relation_for_user(company)
    if can?(:update, company)
      'you are the owner'
    elsif current_user.companies.include?(company)
      'you work here'
    else
      friends_related_to_company = Friend.related_to_company(company.id)
      friends_working_in_company = Friend.working_in_company(company.id)

      user_company_friends_intersection = (current_user.friends & friends_working_in_company)
      user_company_friends_of_friends_intersection = (current_user.friends & friends_related_to_company)

      if user_company_friends_intersection.size > 0
        get_social_relation_weight(user_company_friends_intersection, :friends, company.people.size)
      elsif user_company_friends_of_friends_intersection.size > 0
        get_social_relation_weight(user_company_friends_of_friends_intersection, :friends_of_friends, company.people.size)
      else
        'none'
      end
        
    end
  end

private

  def get_social_relation_weight(intersection, intersection_type, company_people_size)
    company_people_size = company_people_size.to_f
    intersection_size = intersection.size.to_f

    relation = if intersection_type == :friends
      if intersection_size / company_people_size >= 0.1
        'strong'
      else
        'significant'
      end
    elsif intersection_type == :friends_of_friends
      if intersection_size / company_people_size >= 0.5
        'good'
      elsif intersection_size / company_people_size >= 0.3
        'small'
      else
        'tiny'
      end
    end 

    "#{relation} (#{intersection_type.to_s.humanize.underscore} work here: #{intersection.map(&:full_name).join(', ')})"
  end

end
