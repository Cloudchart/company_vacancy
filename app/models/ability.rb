class Ability
  include CanCan::Ability

  def initialize(user)
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
    
    # Anyone
    # 
    can :read, :company_invite

    can :read, Page
    can :read, Event
    can :read, Feature
    can :read, BlockIdentity
    can :read, Event

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
    # User
    # 
    else
      can [:accept, :destroy], :company_invite
      can [:verify, :resend_verification], :email
      can :manage, :main
      can :update, :user

      can :create, CloudProfile::Email
      can [:create, :read, :search], Company
      can :vote, Feature
      can :manage, Subscription
      can [:preview, :read, :pull], CloudBlueprint::Chart

      # User (conditional)
      #
      can :destroy, CloudProfile::Email, user_id: user.id

      can :manage, Company do |company|
        user.roles.find_by(owner: company).try(:value) =~ /owner|editor/
      end

      [Person, Vacancy, Event, Block, BlockIdentity, CloudBlueprint::Chart].each do |model|
        can :manage, model do |resource|
          user.roles.find_by(owner: resource.company).try(:value) =~ /owner|editor/
        end
      end

      can :create_company_invite, Company do |company|
        user.roles.find_by(owner: company).try(:value) == :owner
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

      # can :manage, Comment do |comment|
      #   comment.user == user
      # end

    end
  end
end
