module Preloadable::User
  extend ActiveSupport::Concern

  included do
    include Preloadable

    has_many :companies_roles, -> { where(owner_type: 'Company') }, class_name: 'Role'
    has_many :companies_favorites, -> { where(favoritable_type: 'Company') }, class_name: 'Favorite'
    has_many :pinboards_roles, -> { where(owner_type: 'Pinboard') }, class_name: 'Role'
    has_many :pinboards_favorites, -> { where(favoritable_type: 'Pinboard') }, class_name: 'Favorite'
    has_many :users_favorites, -> { where(favoritable_type: 'User') }, class_name: 'Favorite'

    acts_as_preloadable :companies_through_roles, companies_roles: :company
    acts_as_preloadable :favorite_companies, companies_favorites: :company
    acts_as_preloadable :related_companies, :companies, companies_roles: :company, companies_favorites: :company
    acts_as_preloadable :pinboards_through_roles, pinboards_roles: :pinboard
    acts_as_preloadable :favorite_pinboards, pinboards_favorites: :pinboard
    acts_as_preloadable :related_pinboards, pinboards: :pins, pinboards_roles: { pinboard: :pins }, pinboards_favorites: { pinboard: :pins }
    acts_as_preloadable :related_pinboards_by_date, users_favorites: { favoritable_user: :pinboards }
    acts_as_preloadable :related_pins_by_date, pinboards_favorites: { pinboard: :pins }, users_favorites: { favoritable_user: :pins }
    acts_as_preloadable :insights, :pins

    def companies_through_roles(scope = {})
      companies_roles.map(&:company).select { |c| ability(scope).can?(:read, c) }
    end

    def favorite_companies(scope = {})
      companies_favorites.map(&:company).select { |c| ability(scope).can?(:read, c) }
    end

    def related_companies(scope = {})
      companies.select { |c| ability(scope).can?(:read, c) }
        .concat(companies_through_roles(scope))
        .concat(favorite_companies(scope))
        .uniq
    end

    def pinboards_through_roles(scope = {})
      pinboards_roles.map(&:pinboard).select { |pinboard| ability(scope).can?(:read, pinboard) }
    end

    def favorite_pinboards(scope = {})
      pinboards_favorites.map(&:pinboard).select { |pinboard| ability(scope).can?(:read, pinboard) }
    end

    def related_pinboards(scope = {})
      pinboards.select { |pinboard| ability(scope).can?(:read, pinboard) }
        .concat(pinboards_through_roles(scope))
        .concat(favorite_pinboards(scope))
        .uniq
    end

    def related_pinboards_by_date(scope = {})
      date = Date.today # should be passed as a parameter
      users_favorites
        .flat_map { |favorite| favorite.favoritable_user.pinboards }
        .select { |pinboard| ability(scope).can?(:read, pinboard) && pinboard.created_at.to_date == date }
    end

    def related_pins_by_date(scope = {})
      date = Date.today # should be passed as a parameter
      pt1 = favorite_pinboards(scope).flat_map { |pinboard| pinboard.pins }
      pt2 = users_favorites.flat_map { |favorite| favorite.favoritable_user.pins } # TODO: check private pinboards
      # pt3 = favorite_companies.flat_map(&:posts).flat_map(&:pins) # :(
      (pt1 + pt2).select { |pin| ability(scope).can?(:read, pin) && pin.created_at.to_date == date }
    end

    def insights
      pins.select { |p| p.insight? }
    end

  private

    def ability(scope = {})
      scope[:current_user_ability] ||= Ability.new(scope[:current_user] || self)
    end

  end
end
