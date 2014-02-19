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
    can :read, Company

    return unless user

    # User specific
    can :create, Company
    can [:update, :destroy], Company do |company| 
      user_has_access_to_company?(user, company.id)
    end

    can [:update, :destroy], Block do |block|
      user_has_access_to_company?(user, block.owner_id)
    end

    # can [:manage], Person do |person|
    #   user_has_access_to_company?(user, person.company_id)
    # end

  end

private

  def user_has_access_to_company?(user, company_id)
    user.people.select { |person| person.company_id == company_id }.any?
  end

end
