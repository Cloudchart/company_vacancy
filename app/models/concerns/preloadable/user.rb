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

    FEED_PINBOARDS_RELATIONS = { users_favorites: { favoritable_user: :pinboards } }

    acts_as_preloadable :feed_pinboards, FEED_PINBOARDS_RELATIONS
    acts_as_preloadable :feed_pinboards_by_date, FEED_PINBOARDS_RELATIONS

    FEED_PINS_RELATIONS = { pinboards_favorites: { pinboard: :pins }, users_favorites: { favoritable_user: :pins } }

    acts_as_preloadable :feed_pins, FEED_PINS_RELATIONS
    acts_as_preloadable :feed_pins_by_date, FEED_PINS_RELATIONS

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

    def feed_pinboards(scope = {})
      users_favorites
        .flat_map { |favorite| favorite.favoritable_user.pinboards }
        .select { |pinboard| ability(scope).can?(:read, pinboard) }
    end

    def feed_pinboards_by_date(scope = {})
      date = Date.parse(scope[:params][:date]) rescue Date.today
      feed_pinboards.select { |pinboard| pinboard.created_at.to_date == date }
    end

    def feed_pins(scope = {})
      pins = []
      pins.concat favorite_pinboards(scope).flat_map { |pinboard| pinboard.pins }
      pins.concat users_favorites.flat_map { |favorite| favorite.favoritable_user.pins }
      pins
    end

    def feed_pins_by_date(scope = {})
      date = Date.parse(scope[:params][:date]) rescue Date.today
      feed_pins.select { |pin| pin.created_at.to_date == date }
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
