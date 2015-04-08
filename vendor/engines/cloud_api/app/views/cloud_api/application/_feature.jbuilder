json.(feature, :uuid, :assigned_title, :category)
json.(feature, :featurable_id, :featurable_type)
json.(feature, :created_at)

json.assigned_image_url feature.assigned_image.thumb('1600x>').url