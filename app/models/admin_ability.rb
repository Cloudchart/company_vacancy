class AdminAbility
  include CanCan::Ability

  def initialize(current_user)
    if current_user && current_user.admin?
      # Miscellaneous
      #
      can :access, :rails_admin
      can :dashboard

      can [:index, :update, :destroy, :export], GuestSubscription
      can [:index, :destroy, :invite, :accept_invite], Token
      can [:index, :update, :destroy], Feature
      can [:index, :show_in_app], Company
      can :manage, [Interview, Page, Tag, Domain]

      cannot :export, Interview
      cannot :history, Domain
      cannot :show, [Interview, Page, Tag, Domain]

      # Pin
      #
      can [:index, :update], Pin

      can :approve, Pin do |pin|
        !pin.is_approved?
      end

      # User
      #
      can [:index, :create, :update, :export, :make_unicorns], User
      can [:authorize, :destroy], User, authorized_at: nil

      can :merge, User do |user|
        user.authorized_at.blank? && user.twitter.present? && User.available_for_merge(user).any?
      end

      cannot :update, User do |user|
        user.guest?
      end
      
      # Pinboard
      #
      can [:index, :create], Pinboard

      can [:update, :destroy], Pinboard do |pinboard|
        pinboard.user_id.blank?
      end

      # Story
      #
      can [:index, :create], Story

      can [:update, :destroy], Story do |story|
        story.company_id.blank?
      end

      # Miscellaneous
      #
      can :make_unfeatured, [Company, Pin, Pinboard] do |object|
        object.is_featured?
      end

      can :make_featured, [Company, Pin, Pinboard] do |object|
        !object.is_featured?
      end

    end
  end
end
