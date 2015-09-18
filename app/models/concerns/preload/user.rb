module Preload::User
  extend ActiveSupport::Concern

  included do
    include Preloadable

    has_many :companies_roles, -> { where(owner_type: 'Company') }, class_name: 'Role'
    has_many :companies_favorites, -> { where(favoritable_type: 'Company') }, class_name: 'Favorite'
    has_many :pinboards_roles, -> { where(owner_type: 'Pinboard') }, class_name: 'Role'
    has_many :pinboards_favorites, -> { where(favoritable_type: 'Pinboard') }, class_name: 'Favorite'
    has_many :users_favorites, -> { where(favoritable_type: 'User') }, class_name: 'Favorite'
    has_many :insights_favorites, -> { where(favoritable_type: 'Pin') }, class_name: 'Favorite'

    acts_as_preloadable :companies_through_roles, companies_roles: :company
    acts_as_preloadable :favorite_companies, companies_favorites: :company
    acts_as_preloadable :related_companies, :companies, companies_roles: :company, companies_favorites: :company
    acts_as_preloadable :pinboards_through_roles, pinboards_roles: :pinboard
    acts_as_preloadable :favorite_pinboards, pinboards_favorites: :pinboard
    acts_as_preloadable :related_pinboards, pinboards: :pins, pinboards_roles: { pinboard: :pins }, pinboards_favorites: { pinboard: :pins }
    acts_as_preloadable :available_pinboards, pinboards: :pins, pinboards_roles: { pinboard: :pins }
    acts_as_preloadable :feed_pinboards, { users_favorites: { favoritable_user: :pinboards } }
    acts_as_preloadable :feed_pins, pinboards_favorites: { pinboard: :pins }, users_favorites: { favoritable_user: :pins }
    acts_as_preloadable :insights, :pins
    acts_as_preloadable :favorite_insights, insights_favorites: :favoritable_pin
    acts_as_preloadable :favorite_users, users_favorites: :favoritable_user


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

    def available_pinboards(scope = {})
      pinboards.select { |pinboard| ability(scope).can?(:read, pinboard) }
        .concat(pinboards_through_roles(scope))
        .uniq
    end

    def feed_pinboards(scope = {})
      date = Date.parse(scope[:params][:date]) rescue nil
      users_favorites
        .flat_map { |favorite| favorite.favoritable_user.pinboards }
        .select { |pinboard| ability(scope).can?(:read, pinboard) && (date ? pinboard.created_at.to_date == date : true) }
    end

    def feed_pins(scope = {})
      date = Date.parse(scope[:params][:date]) rescue nil
      pins = []
      pins.concat favorite_pinboards(scope).flat_map { |pinboard| pinboard.pins }
      pins.concat users_favorites.flat_map { |favorite| favorite.favoritable_user.pins }
      pins.select { |pin| ability(scope).can?(:read, pin) && (date ? pin.created_at.to_date == date : true) }
    end

    def insights
      pins.select { |p| p.insight? }
    end

    def favorite_insights
      insights_favorites.map(&:favoritable_pin)
    end

    def favorite_users
      users_favorites.map(&:favoritable_user)
    end

  private

    def ability(scope = {})
      scope[:current_user_ability] ||= Ability.new(scope[:current_user] || self)
    end

  end
end
