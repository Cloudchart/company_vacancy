class Viewer < User

  def featured_companies(scope = {})
    Company.featured.where(features: { scope: Feature.scopes[:main] }).select { |c| ability(scope).can?(:read, c) }
  end

  def published_companies(scope = {})
    Company.published.select { |c| ability(scope).can?(:read, c) }
  end

  def featured_pinboards(scope = {})
    Pinboard.featured.where(features: { scope: Feature.scopes[:main] }).select { |p| ability(scope).can?(:read, p) }
  end

  def feed_featured_pinboards(scope = {})
    get_features_for(Pinboard, scope)
  end

  def feed_featured_posts(scope = {})
    get_features_for(Post, scope)
  end

private

  def ability(scope = {})
    scope[:current_user_ability] ||= Ability.new(scope[:current_user] || self)
  end

  def get_features_for(klass, scope)
    date = Date.parse(scope[:params][:date]) rescue nil
    result = klass.featured.where(features: { scope: Feature.scopes[:feed] })

    if date
      result = result.where('features.effective_from <= ? AND features.effective_till >= ?', date, date)
    end

    result = result.select { |object| ability(scope).can?(:read, object) }
    result
  end

end
