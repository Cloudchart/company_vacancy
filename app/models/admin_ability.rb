class AdminAbility
  include CanCan::Ability

  def initialize(current_user)
    if current_user && current_user.admin?
      # Miscellaneous
      # 
      can :access, :rails_admin
      can :dashboard

      can :index, Person
      can [:index, :update, :destroy, :export], GuestSubscription
      can [:index, :destroy, :invite, :accept_invite], Token
      can :manage, [Interview, Page, Tag, Feature, Domain]

      cannot :export, Interview
      cannot :history, [Feature, Domain]
      cannot :show, [Interview, Page, Tag, Feature, Domain]

      # Pin
      # 
      can [:index, :update], Pin

      can :approve, Pin do |pin|
        !pin.is_approved?
      end

      # User
      # 
      can [:index, :create, :update, :make_unicorns], User
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
      can [:make_important], Pinboard, is_important: false
      can [:make_unimportant], Pinboard, is_important: true


      can [:update, :destroy], Pinboard do |pinboard|
        pinboard.user_id.blank?
      end

      # Story
      # 
      can [:index, :create], Story

      can [:update, :destroy], Story do |story|
        story.company_id.blank?
      end

      # Company
      # 
      can [:index, :show_in_app], Company
      can [:make_important], Company, is_important: false
      can [:make_unimportant], Company, is_important: true

    end
  end
end
