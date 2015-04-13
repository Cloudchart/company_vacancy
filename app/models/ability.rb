class Ability
  include CanCan::Ability

  def initialize(current_user)
    return unless current_user

    # Anyone
    #
    if current_user.guest?
      # can :read, :invite

      # can :read, Event
      # can :read, Event
      # can :read, Tag
      # can :read, Person
      # can :read, Vacancy
      # can :read, Quote
      # can :show, Pinboard
      
      # can [:preview, :read, :pull], CloudBlueprint::Chart, is_public: true
      # can :show, Company, is_public: true

      # can :read, Post do |post|
      #   company = post.company
      #   company.is_public? && company.is_published? && (post.visibilities.blank? || post.visibility.value == 'public')
      # end
      
    # Regular user
    #
    else
      can [:create, :verify, :resend_verification], Email
      can :manage, :cloud_profile_main
      can :update, :cloud_profile_user
      can [:read, :accept, :destroy], :invite

      # can :manage, Subscription
      can :unfollow, Company
      can [:preview, :read, :pull], CloudBlueprint::Chart
      can :create, Tag
      can [:read, :create], Pinboard
      can [:read, :create], Pin

      can [:read, :search], Company, is_published: true
      can [:update, :destroy, :settings], Pinboard, user_id: current_user.id
      can :destroy, Email, user_id: current_user.id

      can :read, User do |user|
        !user.guest?
      end

      can [:update, :settings], User do |user|
        user.id == current_user.id ||
        (current_user.editor? && user.unicorn? && user.last_sign_in_at.blank?)
      end

      can [:update, :destroy], Pin do |pin|
        pin.user_id == current_user.id || current_user.editor?
      end
      
      can :create, Company do |company| 
        current_user.editor?
      end

      can :manage, Company do |company|
        owner?(current_user, company)
      end

      can [:read, :update, :finance, :settings, :access_rights, :verify_site_url, :download_verification_file, :reposition_blocks], Company do |company|
        editor?(current_user, company)
      end

      can [:read, :finance], Company do |company|
        trusted_reader?(current_user, company)
      end

      cannot :follow, Company do |company|
        current_user.companies.map(&:id).include?(company.id)
      end

      can :follow, Company do |company|
        !current_user.companies.map(&:id).include?(company.id)
      end

      can [:follow, :unfollow], User do |user|
        current_user != user
      end

      # TODO: test this
      cannot [:create, :update], Quote do |quote|
        quote.company && !quote.company.people.include?(quote.person)
      end

      can :manage, [Person, Vacancy, Block, CloudBlueprint::Chart, Post, Story, Quote, PostsStory, Paragraph, Picture] do |resource|
        owner_or_editor?(current_user, resource.company)
      end

      can :manage_company_invites, Company do |company|
        owner_or_editor?(current_user, company)
      end

      can [:update, :destroy], Role do |role|
        owner_or_editor?(current_user, role.owner)
      end

      can :manage, Visibility do |visibility|
        owner?(current_user, visibility.owner.try(:owner))
      end

      can :read, Post do |post|
        (post.company.is_published? && (post.visibilities.blank? || post.visibility.value == 'public')) ||
        (post.visibility.try(:value) == 'trusted' && trusted_reader?(current_user, post.company))
      end

      can :manage_pinboard_invites, Pinboard do |pinboard|
        current_user.id == pinboard.user_id || editor?(current_user, pinboard)
      end

    end

  end

private

  def owner?(user, object)
    role_value(user, object) == 'owner'
  end

  def editor?(user, object)
    role_value(user, object) == 'editor'
  end

  def owner_or_editor?(user, object)
    role_value(user, object) =~ /owner|editor/
  end

  def trusted_reader?(user, object)
    role_value(user, object) == 'trusted_reader'
  end

  def role_value(user, object)
    user.roles.select { |role| role.owner_id == object.id }.first.try(:value)
  end

end
