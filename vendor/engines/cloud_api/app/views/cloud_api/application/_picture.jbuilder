json.(picture, :uuid)
json.(picture, :owner_id, :owner_type)
json.(picture, :created_at, :updated_at)
json.(picture, :size)

json.url picture.image.thumb('1600x>').url if picture.image_stored?
