json.(feature, :uuid, :assigned_title, :category)
json.(feature, :featurable_id, :featurable_type)
json.(feature, :created_at)
json.(feature, :is_blurred, :is_darkened)

json.assigned_image_url feature.assigned_image.try(:thumb, '1600x>').try(:url)
json.assigned_url feature.url.present? ? feature.formatted_url : main_app.post_path(feature.insight.post)
