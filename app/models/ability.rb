class Ability
  include CanCan::Ability

  def initialize(user)    
    # Anyone
    # 
    can :read, :company_invite

    can :read, Page
    can :read, Event
    can :read, Feature
    can :read, BlockIdentity
    can :read, Event
    can :read, Tag
    can :read, Post
    can [:read, :accept], Interview

    # TODO: not all (maybe which only belongs to chart)
    can :read, Person
    can :read, Vacancy

    can :read, Company, is_public: true
    can [:preview, :read, :pull], CloudBlueprint::Chart, is_public: true

    # can :read, Vacancy do |vacancy|
    #   vacancy.settings.accessible_to == 'everyone'
    # end

    return unless user

    # Admin
    # 
    if user.is_admin?
      # can :access, :rails_admin
      # can :dashboard
      can :manage, :all

      # TODO: add rules for admin
      # cannot [:create, :update, :destroy], Company

    # User
    # 
    else
      can [:verify, :resend_verification], :cloud_profile_email
      can :manage, :cloud_profile_main
      can :update, :cloud_profile_user
      can [:accept, :destroy], :company_invite
      can :list, :companies

      can [:create, :read, :search, :unfollow], Company
      can :create, CloudProfile::Email
      can :vote, Feature
      can :manage, Subscription
      can [:preview, :read, :pull], CloudBlueprint::Chart
      can :create, Tag

      # User (conditional)
      #
      can :destroy, CloudProfile::Email, user_id: user.id
      # can :manage, Comment, user_id: user.id

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
        user.companies.pluck(:uuid).include?(company.id)
      end

      can :follow, Company do |company|
        !user.companies.pluck(:uuid).include?(company.id)
      end

      [Person, Vacancy, Event, Block, BlockIdentity, CloudBlueprint::Chart, Post, Story].each do |model|
        can :manage, model do |resource|
          owner_or_editor?(user, resource.company)
        end
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

      # can :read, Vacancy do |vacancy|
      #   user.vacancy_ids.include?(vacancy.id) ||
      #   vacancy.settings.accessible_to =~ /company|company_plus_one_share/ && user.company_ids.include?(vacancy.company_id) ||
      #   vacancy.settings.accessible_to == 'company_plus_one_share' && user.friends.working_in_company(vacancy.company_id).any? ||
      #   vacancy.settings.accessible_to == 'everyone'        
      # end

      # can :manage, VacancyResponse do |vacancy_response|
      #   user.company_access_rights.find_by(company_id: vacancy_response.vacancy.company_id).try(:role) =~ /owner|editor/ ||
      #   user.vacancy_ids.include?(vacancy_response.vacancy_id)
      # end

      # can :access_vacancy_responses, Vacancy do |vacancy|
      #   user.company_access_rights.find_by(company_id: vacancy.company_id).try(:role) =~ /owner|editor/ ||
      #   user.vacancy_ids.include?(vacancy.id) ||
      #   (vacancy.reviewers & user.people).any?
      # end

      # can :create, VacancyResponse do |vacancy_response|
      #   !user.vacancy_responses.pluck(:vacancy_id).include?(vacancy_response.vacancy_id) &&
      #   !user.company_ids.include?(vacancy_response.vacancy.company_id) &&
      #   vacancy_response.vacancy.status == 'opened' &&
      #   !vacancy_response.vacancy.company.banned_users.pluck(:uuid).include?(user.id)
      # end

      # can [:read, :vote], VacancyResponse do |vacancy_response|
      #   (vacancy_response.vacancy.reviewers & user.people).any? &&
      #   vacancy_response.status == 'in_review'
      # end
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
    company.roles.select { |role| role.user_id == user.id }.first.try(:value)
  end

end
