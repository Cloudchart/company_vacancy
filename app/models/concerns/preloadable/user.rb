module Preloadable::User
  extend ActiveSupport::Concern

  included do
    include Preloadable

    has_many :companies_roles, -> { where(owner_type: Company.name) }, class_name: Role.name
    has_many :companies_favorites, -> { where(favoritable_type: Company.name) }, class_name: Favorite.name

    acts_as_preloadable :companies_through_roles, companies_roles: :company
    acts_as_preloadable :favorite_companies, companies_favorites: :company
    acts_as_preloadable :related_companies, [:companies, companies_roles: :company, companies_favorites: :company]

    def companies_through_roles(scope = {})
      companies_roles.map(&:company).select { |c| ability(scope).can?(:read, c) }
    end

    def favorite_companies(scope = {})
      companies_favorites.map(&:company).select { |c| ability(scope).can?(:read, c) }
    end

    def related_companies(scope = {})
      ability = ability(scope)
      companies.select { |c| ability.can?(:read, c) }
        .concat(companies_through_roles(ability: ability))
        .concat(favorite_companies(ability: ability))
        .uniq
    end

  private

    def ability(scope)
      scope[:ability] || Ability.new(scope[:current_user] || self)
    end

  end
end
