class AdminAbility
  include CanCan::Ability

  def initialize(current_user)
    if current_user && current_user.admin?
      # Miscellaneous
      # 
      can :access, :rails_admin
      can :dashboard

      can :read, Person
      can :manage, [Interview, Page, Tag, Token, Feature]

      # Pin
      # 
      can [:read, :update], Pin

      can :approve, Pin do |pin|
        !pin.is_approved?
      end

      # User
      # 
      can [:read, :create, :update, :make_unicorns], User
      can [:authorize, :destroy], User, authorized_at: nil

      can :merge, User do |user|
        user.authorized_at.blank? && user.twitter.present? && User.available_for_merge(user).any?
      end

      cannot :update, User do |user|
        user.guest?
      end
      
      # Pinboard
      # 
      can [:read, :create], Pinboard
      can [:make_important], Pinboard, is_important: false
      can [:make_unimportant], Pinboard, is_important: true


      can [:update, :destroy], Pinboard do |pinboard|
        pinboard.user_id.blank?
      end

      # Story
      # 
      can [:read, :create], Story

      can [:update, :destroy], Story do |story|
        story.company_id.blank?
      end

    end
  end
end
