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

json.user_url    main_app.user_path(user)
json.avatar_url  user.avatar.thumb('512x512>').url if user.avatar_stored?


# Edges
#

json_edge! json, :companies_through_roles, edges do
  User.preload_companies_through_roles(siblings, cache)

  user.companies_through_roles({ current_user: current_user }).map do |c|
    {
      id:   c.id,
      name: c.name
    }
  end
end

#
# / Edges
