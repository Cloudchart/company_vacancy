data = {
  users:      [],
  pinboards:  [],
  roles:      []
}


# User
#
data[:users] << @user


# System Roles
#
@user.system_roles.flatten.uniq.each do |role|
  data[:roles] << role
end


# Pinboards
#
@user.available_pinboards.flatten.compact.uniq.each do |pinboard|
  data[:pinboards] << pinboard
end


# Render
#
data.each do |key, values|
  name = key.to_s.singularize
  json.set! key, values do |value|
    json.partial! name, :"#{name}" => value
  end
end
