json.(user, :uuid)
json.(user, :first_name, :last_name, :full_name, :company, :occupation, :twitter)
json.(user, :created_at, :updated_at)

json.email begin
  preload_associations(siblings, cache, :emails)

  user.email
end

json.is_editable begin
  preload_associations(siblings, cache, :roles)

  can?(:update, user)
end

json.user_url     main_app.user_path(user)
json.url          main_app.user_path(user)
json.avatar_url   user.avatar.thumb('512x512>').url if user.avatar_stored?


# Edges
#
json_edge! json, :is_editor, edges do
  preload_associations(siblings, cache, :roles)
  !!user.roles.find { |r| r.owner_id.blank? && r.owner_type.blank? && r.value == 'editor' }
end

json_edge! json, :related_companies, edges do
  User.preload_related_companies(siblings, cache)

  user.related_companies({ current_user: current_user }).map do |c|
    {
      id:     c.id,
      name:   c.name
    }
  end
end

json_edge! json, :is_followed, edges do
  preload_associations(siblings, cache, :favorites)
  user.favorites.select { |f| f.favoritable_type == 'User' }.map { |f| f.favoritable_id }.include?(current_user.id)
end

json_edge! json, :companies_through_roles, edges do
  User.preload_companies_through_roles(siblings, cache)

  user.companies_through_roles({ current_user: current_user }).map do |c|
    {
      id:     c.id,
      name:   c.name
    }
  end
end

json_edge! json, :favorite_companies, edges do
  User.preload_favorite_companies(siblings, cache)

  user.favorite_companies({ current_user: current_user }).map do |c|
    {
      id:     c.id,
      name:   c.name
    }
  end

end

json_edge! json, :insights, edges do
  User.preload_insights(siblings, cache)

  user.insights.map  do |i|
    {
      id: i.id
    }
  end
end

json_edge! json, :related_pinboards, edges do
  User.preload_related_pinboards(siblings, cache)

  user.related_pinboards.map do |pinboard|
    {
      id:         pinboard.id,
      uuid:       pinboard.id,
      title:      pinboard.title,
      pins_count: pinboard.pins.size
    }
  end
end

json_edge! json, :pinboards, edges do
  preload_associations(siblings, cache, :pinboards)

  user.pinboards.map do |p|
    {
      id:     p.id,
      name:   p.title
    }
  end
end

json_edge! json, :pinboards_through_roles, edges do
  User.preload_pinboards_through_roles(siblings, cache)

  user.pinboards_through_roles({ current_user: current_user }).map do |c|
    {
      id:     c.id,
      name:   c.title
    }
  end
end


json_edge! json, :feed_dates, edges do
  User.preload_feed_pinboards(siblings, cache)
  User.preload_feed_pins(siblings, cache)

  dates = []
  dates.concat user.feed_pinboards.map { |p| p.created_at.to_date }
  dates.concat user.feed_pins.map { |p| p.created_at.to_date }
  dates.uniq.sort
end
