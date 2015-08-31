class Ability
  include CanCan::Ability

  def initialize(current_user)
    return unless current_user

    # Anyone
    #
    if current_user.guest?
      can :read, Landing
      can [:search, :share], Pin
      can :read, Pin, is_approved: true
      can :read, Company, is_published: true
      can [:index, :search], :companies
      can :index, :pinboards
      can [:create, :verify], GuestSubscription

      can :read, Pinboard do |pinboard|
        pinboard.public?
      end

      can :read, User do |user|
        !user.guest?
      end

      can :read, Post do |post|
        post.company.is_published? && post.public?
      end

    # Regular user
    #
    else
      can :manage, :cloud_profile_main
      can :update, :cloud_profile_user
      can [:read, :accept, :destroy], :company_invite

      can :read, Paragraph
      can :create, Tag
      can :create, Activity
      can [:create, :verify, :resend_verification], Email
      can :destroy, Email, user_id: current_user.id

      can :manage, :invite do
        current_user.inviter?
      end

      # User
      #
      can :feed, User

      can :read, User do |user|
        !user.guest?
      end

      can [:update, :settings], User do |user|
        user.id == current_user.id ||
        (current_user.editor? && user.unicorn? && user.last_sign_in_at.blank?)
      end

      can [:follow, :unfollow], User do |user|
        current_user != user
      end

      can [:subscribe, :unsubscribe], User do |user|
        current_user == user
      end

      # Pin
      #
      can [:follow, :unfollow, :search, :share], Pin

      # TODO: separate actions
      can :create, Pin do |pin|
        if pin.pinboard
          (owner?(current_user, pin.pinboard) || editor_or_contributor?(current_user, pin.pinboard)) ||
          (current_user.editor? && owner_or_editor?(pin.user, pin.pinboard)) ||
          (pin.is_suggestion? && pin.pinboard.suggestion_rights == 'anyone')
        elsif pin.kind == 'reflection'
          true
        else
          current_user.editor? && pin.is_suggestion?
        end
      end

      can :read, Pin do |pin|
        pin.content.blank? || pin.is_approved? || pin.user_id == current_user.id ||
        (current_user.admin? || current_user.editor?)
      end

      can :approve, Pin do |pin|
        (current_user.admin? || current_user.editor?) && pin.content.present? && !pin.is_approved?
      end

      can [:update, :destroy], Pin do |pin|
        pin.user_id == current_user.id || current_user.editor?
      end

      # Company
      #
      can :manage, Company, user_id: current_user.id
      can [:follow, :unfollow], Company
      can :read, Company, is_published: true
      can [:index, :search], :companies

      can :create, Company do
        current_user.editor?
      end

      can [:read, :update, :finance, :settings, :access_rights, :verify_site_url, :download_verification_file, :reposition_blocks], Company do |company|
        editor?(current_user, company)
      end

      can [:read, :finance], Company do |company|
        trusted_reader?(current_user, company)
      end

      can :read, Company do |company|
        public_reader?(current_user, company)
      end

      can :manage_company_invites, Company do |company|
        owner_or_editor?(current_user, company)
      end

      # Pinboard
      #
      can :index, :pinboards
      can :create, Pinboard
      can [:destroy], Pinboard, user_id: current_user.id

      can [:read, :follow, :unfollow], Pinboard do |pinboard|
        pinboard.public? || current_user.id == pinboard.user_id || reader_or_editor?(current_user, pinboard)
      end

      can [:request_access], Pinboard do |pinboard|
        cannot?(:read, pinboard) && pinboard.protected?
      end

      can [:update, :settings, :manage_pinboard_invites], Pinboard do |pinboard|
        current_user.id == pinboard.user_id || editor?(current_user, pinboard)
      end

      can :add_insight, Pinboard do |pinboard|
        (owner?(current_user, pinboard) || editor_or_contributor?(current_user, pinboard)) ||
        (current_user.editor? && pinboard.user.unicorn?)
      end

      # Token
      #
      can :read, Token

      can :create_greeting, User do |user|
        user != current_user && current_user.editor? && user.unicorn?
      end

      can [:update_greeting], Token do |token|
        current_user.editor?
      end

      can :destroy_greeting, Token do |token|
        current_user.editor? || token.owner == current_user
      end

      can [:destroy_welcome_tour, :destroy_insight_tour], Token do |token|
        token.owner == current_user
      end

      # Landing
      #
      can :read, Landing

      can :create, Landing do |landing|
        current_user.editor?
      end

      can [:update, :destroy], Landing, author_id: current_user.id

      # Role
      #
      can [:read, :accept], Role

      can [:create, :update], Role do |role|
        owner_or_editor?(current_user, role.owner)
      end

      can :destroy, Role do |role|
        role.user_id == current_user.id || owner_or_editor?(current_user, role.owner)
      end

      # Miscellaneous
      #
      cannot [:create, :update], Quote do |quote|
        quote.company && !quote.company.people.include?(quote.person)
      end

      can :manage, [Person, Block, Post, Story, Quote, PostsStory, Paragraph, Picture] do |resource|
        owner_or_editor?(current_user, resource.company)
      end

      can :manage, Visibility do |visibility|
        owner_or_editor?(current_user, visibility.owner.try(:owner))
      end

      can :read, Post do |post|
        ((post.company.is_published? || public_reader?(current_user, post.company)) && (post.visibilities.blank? || post.visibility.value == 'public')) ||
        (post.visibility.try(:value) == 'trusted' && trusted_reader?(current_user, post.company))
      end

    end

  end

private

  %w(editor reader contributor).each do |role|
    define_method("#{role}?") do |user, object|
      role_value(user, object) == role
    end
  end

  def owner?(user, object)
    object.user_id == user.id
  end

  def reader_or_editor?(user, object)
    role_value(user, object) =~ /reader|editor/
  end

  def editor_or_contributor?(user, object)
    role_value(user, object) =~ /editor|contributor/
  end

  def owner_or_editor?(user, object)
    return false unless object
    owner?(user, object) || editor?(user, object)
  end

  def trusted_reader?(user, object)
    role_value(user, object) == 'trusted_reader'
  end

  def public_reader?(user, object)
    role_value(user, object) == 'public_reader'
  end

  def role_value(user, object)
    user.roles.select { |role| role.owner_id == object.id }.first.try(:value)
  end

end
