json.(user, :uuid)
json.(user, :first_name, :last_name, :full_name, :email)
json.(user, :created_at, :updated_at)

json.avatar_url user.avatar.thumb('512x512>').url if user.avatar_stored?
