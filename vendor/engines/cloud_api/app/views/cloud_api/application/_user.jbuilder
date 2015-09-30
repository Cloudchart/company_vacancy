json.(user, :uuid)
json.(user, :first_name, :last_name, :full_name, :company, :occupation, :twitter)
json.(user, :created_at, :updated_at)
json.(user, :notification_types)

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
json_edge! json, :values_for_notification_types, edges do
  User.values_for_notification_types
end

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
  current_user.users_favorites.map(&:favoritable_id).include?(user.id)
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


json_edge! json, :insights_ids, edges do
  User.preload_insights(siblings, cache)
  user.insights.map(&:id)
end


json_edge! json, :favorite_insights_ids, edges do
  User.preload_favorite_insights(siblings, cache)
  user.favorite_insights.map(&:id)
end


json_edge! json, :related_pinboards, edges do
  User.preload_related_pinboards(siblings, cache)

  user.related_pinboards.select do |pinboard|
    scope[:current_user_ability].can?(:read, pinboard)
  end.map do |pinboard|
    {
      id:         pinboard.id,
      uuid:       pinboard.id,
      title:      pinboard.title,
      pins_count: pinboard.pins.size
    }
  end
end

json_edge! json, :available_pinboards_ids, edges do
  User.preload_available_pinboards(siblings, cache)
  user.available_pinboards(current_user: current_user).map(&:id)
end


json_edge! json, :favorite_pinboards_ids, edges do
  User.preload_favorite_pinboards(siblings, cache)
  user.favorite_pinboards(current_user: current_user).map(&:id)
end

json_edge! json, :favorite_users_ids, edges do
  User.preload_favorite_users(siblings, cache)
  user.favorite_users.map(&:id)
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

json_edge! json, :pinboard_ids, edges do
  preload_associations(siblings, cache, :pinboards)
  user.pinboards.map(&:id)
end

json_edge! json, :pinboards_through_roles, edges do
  User.preload_pinboards_through_roles(siblings, cache)

  user.pinboards_through_roles({ current_user: current_user }).map do |pinboard|
    {
      id:     pinboard.id,
      name:   pinboard.title
    }
  end
end
