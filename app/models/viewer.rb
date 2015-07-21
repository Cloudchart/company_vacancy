class Viewer < User

  def featured_companies(scope = {})
    Company.featured.select { |c| ability(scope).can?(:read, c) }
  end

  def published_companies(scope = {})
    Company.published.select { |c| ability(scope).can?(:read, c) }
  end

  def featured_pinboards(scope = {})
    Pinboard.featured.select { |p| ability(scope).can?(:read, p) }
  end

private

  def ability(scope = {})
    scope[:current_user_ability] ||= Ability.new(scope[:current_user] || self)
  end

end
