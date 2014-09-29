module CompaniesHelper

  def og_company_name(company)
    prefix = company.name == 'CloudChart' ? '' : 'CloudChart: '
    "#{prefix}#{company.name}"
  end
  
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

  # TODO: refactor
  def proximity(company, user = current_user)
    # initialize result
    #
    result = OpenStruct.new

    # calculate index
    #
    if user == current_user && can?(:update, company)
      result.index = 7 # you are the owner
    elsif user.companies.include?(company)
      result.index = 6 # you work here
    else
      friends_working_in_company = Friend.working_in_company(company.id)
      friends_related_to_company = Friend.related_to_company(company.id)

      user_company_friends_intersection = (user.friends & friends_working_in_company)
      user_company_friends_of_friends_intersection = (user.friends & friends_related_to_company)

      result.index = if user_company_friends_intersection.size > 0
        calculate_proximity_index(user_company_friends_intersection, :friends, company.people.size)
      elsif user_company_friends_of_friends_intersection.size > 0
        calculate_proximity_index(user_company_friends_of_friends_intersection, :friends_of_friends, company.people.size)
      else
        0
      end
    end

    # concatenate message
    #
    result.message = t("companies.proximity.#{result.index}")

    if result.index == 5 || result.index == 4
      result.message << ". #{t('companies.proximity.friends')}: " 
      result.message <<  user_company_friends_intersection.map(&:full_name).join(', ')
      result.message << '.'
    elsif result.index >= 1 && result.index <= 3
      result.message << ". #{t('companies.proximity.friends_of_friends')}: " 
      result.message <<  user_company_friends_of_friends_intersection.map(&:full_name).join(', ')
      result.message << '.'      
    end

    # return result
    #
    result
  end

  def show_companies_counter(companies)
    ''.tap do |content|
      if companies.size > 0
        content << companies.size.to_s
        content << ' '
      end
      
      content << t("companies.search.companies", count: companies.size)
      
    end.html_safe    
  end

private

  def calculate_proximity_index(intersection, intersection_type, company_people_size)
    company_people_size = company_people_size.to_f
    intersection_size = intersection.size.to_f

    relation = if intersection_type == :friends
      if intersection_size / company_people_size >= 0.1
        5 # strong
      else
        4 # significant
      end
    elsif intersection_type == :friends_of_friends
      if intersection_size / company_people_size >= 0.5
        3 # good
      elsif intersection_size / company_people_size >= 0.3
        2 # small
      else
        1 # tiny
      end
    end
  end

end
