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

  def calculate_proximity(company)
    if can?(:update, company)
      'You are the owner'
    elsif current_user.companies.include?(company)
      'You work here'
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
        'None'
      end
        
    end
  end

  def show_companies_counter(companies)
    ''.tap do |content|
      if companies.size > 0
        content << companies.size.to_s
        content << ' '
      end

      if companies.facets && companies.facets['industries']['count'] > 0
        content << content_tag(:span, companies.first.industry.name, class: 'green')
        content << ' '
      end
      
      content << t("companies.search.companies", count: companies.size)

      if companies.facets && companies.facets['countries']['count'] > 0
        content << ' from '
        content << content_tag(:span, companies.first.country, class: 'green')
      end
    end.html_safe    
  end

private

  def get_social_relation_weight(intersection, intersection_type, company_people_size)
    company_people_size = company_people_size.to_f
    intersection_size = intersection.size.to_f

    relation = if intersection_type == :friends
      if intersection_size / company_people_size >= 0.1
        'Strong'
      else
        'Significant'
      end
    elsif intersection_type == :friends_of_friends
      if intersection_size / company_people_size >= 0.5
        'Good'
      elsif intersection_size / company_people_size >= 0.3
        'Small'
      else
        'Tiny'
      end
    end 

    "#{relation} (#{intersection_type.to_s.humanize.underscore} work here: #{intersection.map(&:full_name).join(', ')})"
  end

end
