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

json_edge! json, :feed_pins_by_date, edges do
  User.preload_feed_pins_by_date(siblings, cache)

  user.feed_pins_by_date({ current_user: current_user, params: params }).map do |pin|
    {
      id: pin.id,
      created_at: pin.created_at
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

json_edge! json, :feed_pinboards_by_date, edges do
  User.preload_feed_pinboards_by_date(siblings, cache)

  user.feed_pinboards_by_date({ current_user: current_user, params: params }).map do |pinboard|
    {
      id: pinboard.id,
      created_at: pinboard.created_at
    }
  end
end


json_edge! json, :next_feed_date, edges do
  User.preload_feed_pinboards(siblings, cache)
  User.preload_feed_pins(siblings, cache)

  dates = []

  dates.concat user.feed_pinboards.map { |p| p.created_at.to_date }
  dates.concat user.feed_pins.map { |p| p.created_at.to_date }
  dates = dates.uniq.sort

  if params[:date].present? && date = Date.parse(params[:date])
    dates.select { |d| d < date }.last
  else
    dates.last
  end
end
