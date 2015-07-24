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


  def popular_pinboards(scope = {})
    Favorite.includes(:pinboard).where(favoritable_type: Pinboard.name).group_by do |favorite|
      favorite.pinboard
    end.select do |pinboard, favorites|
      favorites.size > Cloudchart::POPULAR_PINBOARDS[:followers_count] && pinboard.access_rights == 'public'
    end.keys.take(Cloudchart::POPULAR_PINBOARDS[:pinboards_count])
  end


private

  def ability(scope = {})
    scope[:current_user_ability] ||= Ability.new(scope[:current_user] || self)
  end

end
