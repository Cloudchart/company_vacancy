json.role do
  json.partial! 'role', role: @role
end

json.user do
  json.partial! 'user', user: @role.user
end