class AdminAbility
  include CanCan::Ability

  def initialize(current_user)
    if current_user && current_user.admin?
      can :access, :rails_admin
      can :dashboard

      can :read, Person
      can [:read, :update], Pin
      can [:read, :create, :update, :make_unicorns], User
      can [:read, :create], Story
      can [:read, :create], Pinboard

      can :manage, [Interview, Page, Tag, Token, Feature]

      can [:authorize, :destroy], User, authorized_at: nil

      can :merge, User do |user|
        user.authorized_at.blank? && user.twitter.present? && User.available_for_merge(user).any?
      end

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
