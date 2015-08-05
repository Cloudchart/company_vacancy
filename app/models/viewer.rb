class Viewer < User

  def published_companies(scope = {})
    Company.published.select { |c| ability(scope).can?(:read, c) }
  end

  def main_features
    Feature.main.active
  end

  def feed_features
    Feature.feed.active
  end

  def feed_featured_pinboards(scope = {})
    get_features_for(Pinboard, scope)
  end

  def feed_featured_posts(scope = {})
    get_features_for(Post, scope)
  end

  def feed_featured_paragraphs(scope = {})
    get_features_for(Paragraph, scope)
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
