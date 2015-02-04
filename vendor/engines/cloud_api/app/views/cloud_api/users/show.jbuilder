data = {
  pinboards:      [],
  system_roles:   []
}


# System Roles
#
@user.system_roles.flatten.uniq.each do |role|
  data[:system_roles] << role
end


# Pinboards
#
@user.available_pinboards.flatten.compact.uniq.each do |pinboard|
  data[:pinboards] << pinboard
end


# Render
#
data.each do |key, values|
  json.set! key, values
end
