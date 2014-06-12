class Ability
  include CanCan::Ability

  def initialize(user)
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
    
    # Anyone
    can [:read, :search], Company

    can :read, Vacancy do |vacancy|
      vacancy.settings.accessible_to == 'everyone'
    end

    can :read, Event
    can :read, Feature

    return unless user

    # Admin
    if user.is_admin?
      # can :access, :rails_admin
      # can :dashboard
      can :manage, :all
    # User
    else
      can :create, Company
      can :vote, Feature
      can :destroy, Token
      can :manage, Subscription
      can :access_vacancies, Company
      can :access_events, Company

      # User (conditional)
      can [:update, :destroy, :upload_logo], Company do |company| 
        (user.people & company.people).first.try(:is_company_owner?)
      end

      can :manage, Block do |block|
        (user.people & block.company.people).first.try(:is_company_owner?)
      end

      [Person, Vacancy, Event].each do |model|
        can :manage, model do |resource|
          (user.people & resource.company.people).first.try(:is_company_owner?)
        end
      end

      can [:access_people], Company do |company|
        user.companies.include?(company)
      end

      can :read, Vacancy do |vacancy|
        vacancy.settings.accessible_to =~ /company|company_plus_one_share/ && user.companies.include?(vacancy.company) ||
        vacancy.settings.accessible_to == 'company_plus_one_share' && user.friends.working_in_company(vacancy.company_id).any? ||
        vacancy.settings.accessible_to == 'everyone'        
      end

    end
  end
end
