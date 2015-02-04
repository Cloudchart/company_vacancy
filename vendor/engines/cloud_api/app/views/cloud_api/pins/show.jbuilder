data = {
  pins:       [],
  users:      []
}


# User
#
data[:pins] << @pin


# Users
#
data[:users] << @pin.user


# Render
#
data.each do |key, values|
  name = key.to_s.singularize
  json.set! key, values do |value|
    json.partial! name, :"#{name}" => value
  end
end
