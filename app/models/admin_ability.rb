class AdminAbility
  include CanCan::Ability

  def initialize(user)
    if user && user.is_admin?
      can :access, :rails_admin
      can :dashboard

      can :read, Person
      can [:read, :update], User
      can [:read, :create], Story
      can [:read, :create], Pinboard

      can :manage, [Feature, Interview, Page, Tag, Token]

      # can :update, User do |u|
      #   !u.is_admin?
      # end

      can [:update, :destroy], Pinboard do |pinboard|
        pinboard.user_id.blank?
      end

      can [:update, :destroy], Story do |story|
        story.company_id.blank?
      end

    end
  end
end
