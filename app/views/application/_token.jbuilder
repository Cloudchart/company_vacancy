json.(token, :uuid, :name, :data)
json.(token, :owner_id, :owner_type)
json.(token, :created_at, :updated_at)

json.rfc1751 Cloudchart::RFC1751::encode(token.to_param)
