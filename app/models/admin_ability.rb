class AdminAbility
  include CanCan::Ability

  def initialize(user)
    if user && user.admin?
      can :access, :rails_admin
      can :dashboard

      can :read, Person
      can [:read, :update], Pin
      can [:read, :create, :update, :make_unicorns], User
      can [:read, :create], Story
      can [:read, :create], Pinboard
      can [:read, :destroy], Feature

      can :manage, [Interview, Page, Tag, Token]

      can [:authorize, :destroy], User, authorized_at: nil

      can [:update, :destroy], Pinboard do |pinboard|
        pinboard.user_id.blank?
      end

      can [:update, :destroy], Story do |story|
        story.company_id.blank?
      end

      cannot :update, User do |user|
        user.guest?
      end

    end
  end
end
