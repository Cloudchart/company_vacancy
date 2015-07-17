json.(person, :uuid, :user_id, :company_id)
json.(person, :full_name, :first_name, :last_name, :twitter, :birthday, :bio)
json.(person, :email, :phone, :int_phone, :skype, :occupation)
json.(person, :created_at, :updated_at)
json.(person, :is_verified)

json.(person, :hired_on, :fired_on)

json.(person, :salary, :stock_options)

json.avatar_url person.avatar.thumb('512x512>').url if person.avatar_stored?
