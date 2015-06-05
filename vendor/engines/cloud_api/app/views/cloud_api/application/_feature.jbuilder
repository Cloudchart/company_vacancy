json.(feature, :uuid, :assigned_title, :category)
json.(feature, :featurable_id, :featurable_type)
json.(feature, :created_at)

json.assigned_image_url feature.assigned_image.try(:thumb, '1600x>').try(:url)
json.assigned_url feature.url.present? ? feature.formatted_url : main_app.post_path(feature.insight.post)
json.is_blurred feature.display_types.include?(:blurred)
json.is_darkened feature.display_types.include?(:darkened)
