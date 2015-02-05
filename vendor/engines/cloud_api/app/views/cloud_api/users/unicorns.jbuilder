data = {
  users:      [],
  roles:      [],
  pinboards:  []
}


users = User.unicorns.includes(:system_roles, :pinboards)


# Users
#
users.flatten.uniq.each do |user|
  data[:users] << user
end


# Roles
#
users.map(&:roles).flatten.compact.uniq.each do |role|
  data[:roles] << role
end


# Pinboards
#
users.map(&:pinboards).flatten.compact.uniq.each do |pinboard|
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
