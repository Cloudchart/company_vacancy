class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    # Anyone
    #
    if user.guest?
      can :read, :company_invite

      can :read, Page
      can :read, Event
      can :read, Feature
      can :read, BlockIdentity
      can :read, Event
      can :read, Tag
      can [:read, :accept], Interview
      can :read, Person
      can :read, Vacancy
      can :read, Quote
      
      can [:preview, :read, :pull], CloudBlueprint::Chart, is_public: true
      can :read, Company, is_public: true

      can :read, Post do |post|
        company = post.company
        company.is_public? && company.is_published? && (post.visibilities.blank? || post.visibility.value == 'public')
      end

      cannot :index, Company
      
    # Regular user
    #
    else
      can [:verify, :resend_verification], :cloud_profile_email
      can :manage, :cloud_profile_main
      can :update, :cloud_profile_user
      can [:accept, :destroy], :company_invite

      can :index, Company
      can [:create, :read, :search, :unfollow], Company
      can :create, CloudProfile::Email
      can :vote, Feature
      can :manage, Subscription
      can [:preview, :read, :pull], CloudBlueprint::Chart
      can :create, Tag

      can :destroy, CloudProfile::Email, user_id: user.id

      can :manage, Company do |company|
        owner?(user, company)
      end

      can [:update, :finance, :settings, :access_rights, :verify_site_url, :download_verification_file, :reposition_blocks], Company do |company|
        editor?(user, company)
      end

      can [:finance], Company do |company|
        trusted_reader?(user, company)
      end

      cannot :follow, Company do |company|
        user.companies.map(&:id).include?(company.id)
      end

      can :follow, Company do |company|
        !user.companies.map(&:id).include?(company.id)
      end

      can :manage, [Person, Vacancy, Event, Block, BlockIdentity, CloudBlueprint::Chart, Post, Story, Quote, PostsStory] do |resource|
        owner_or_editor?(user, resource.company)
      end

      can :manage_company_invites, Company do |company|
        owner_or_editor?(user, company)
      end

      can [:update, :destroy], Role do |role|
        owner_or_editor?(user, role.owner)
      end

      can :manage, Visibility do |visibility|
        owner?(user, visibility.owner.try(:owner))
      end

      cannot [:create, :update], Quote do |quote|
        quote.company && !quote.company.people.include?(quote.person)
      end

      can :read, Post do |post|
        (post.company.is_published? && (post.visibilities.blank? || post.visibility.value == 'public')) ||
        (post.visibility.try(:value) == 'trusted' && trusted_reader?(user, post.company))
      end
    end

  end

private

  def owner?(user, company)
    role_value(user, company) == 'owner'
  end

  def editor?(user, company)
    role_value(user, company) == 'editor'
  end

  def owner_or_editor?(user, company)
    role_value(user, company) =~ /owner|editor/
  end

  def trusted_reader?(user, company)
    role_value(user, company) == 'trusted_reader'
  end

  def role_value(user, company)
    user.roles.select { |role| role.owner_id == company.id }.first.try(:value)
  end

end
