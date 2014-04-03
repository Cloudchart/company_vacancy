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
    can [:create, :activate, :reactivate], User

    can [:read, :search], Company
    [Person, Vacancy, Event].each do |model|
      can [:read], model
    end

    can [:read], Feature

    return unless user

    # Admin
    if user.is_admin?
      # can :access, :rails_admin
      # can :dashboard
      can :manage, :all
    # User
    else
      can :associate_with_person, User
      can :access_social_networks, User
      can :vote, Feature

      # What user can do with conditions
      can [:read, :update, :destroy], User, id: user.id

      can :create, Company
      can [:update, :destroy], Company do |company| 
        (company.people & user.people).any?
      end

      can :manage, Block do |block|
        (block.company.try(:people) & user.people).any?
      end

      # authorization for nested company resorces
      [Person, Vacancy, Event].each do |model|
        can :manage, model do |resource|
          (resource.company.people & user.people).any?
        end
        can [:"access_#{model.table_name}"], Company do |company|
          (company.people & user.people).any?
        end
      end

    end
  end
end
