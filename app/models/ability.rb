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
    
    # Public
    can [:create, :activate, :reactivate], User
    can :read, Company

    return unless user

    # User
    can [:read, :update, :destroy], User, id: user.id
    can :associate_with_person, User do |user|
      !!user
    end

    can :create, Company
    can [:update, :destroy], Company do |company| 
      (company.people & user.people).any?
    end

    can :manage, Block do |block|
      (block.owner.try(:people) & user.people).any?
    end

    can :manage, Person do |person|
      (person.company.people & user.people).any?
    end
    # custom authorization for nested people#index
    can [:access_people], Company do |company|
      (company.people & user.people).any?
    end

    can :manage, Vacancy do |vacancy|
      (vacancy.company.people & user.people).any?
    end
    # custom authorization for nested vacancies#index
    can [:access_vacancies], Company do |company|
      (company.people & user.people).any?
    end

    can :access_social_networks, User do |user|
      !!user
    end    

    can :manage, Token do |token|
      !!user
    end

  end

end
