json.(user, :uuid)
json.(user, :first_name, :last_name, :full_name, :email, :company, :occupation, :twitter)
json.(user, :created_at, :updated_at)

json.user_url   main_app.user_path(user)
json.avatar_url user.avatar.thumb('512x512>').url if user.avatar_stored?
