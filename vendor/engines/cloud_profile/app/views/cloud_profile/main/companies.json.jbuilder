json.partial! 'companies/temp', companies: @companies

json.roles do
  json.partial! 'role', collection: @roles, as: :role
end

json.favorites do
  json.partial! 'favorite', collection: @favorites, as: :favorite
end

json.tokens do
  json.partial! 'token', collection: @tokens, as: :token
end