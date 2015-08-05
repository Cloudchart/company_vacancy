json.(feature, :uuid, :scope, :assigned_title, :position, :display_types)
json.(feature, :featurable_id, :featurable_type)
json.(feature, :created_at, :updated_at)

json.assigned_image_url feature.assigned_image.try(:thumb, '1600x>').try(:url)
