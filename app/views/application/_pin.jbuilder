json.(pin, :uuid, :user_id, :parent_id, :pinboard_id, :source_user_id)
json.(pin, :pinnable_id, :pinnable_type)
json.(pin, :content, :origin)
json.(pin, :pins_count, :weight)
json.(pin, :is_approved, :is_suggestion)
json.(pin, :created_at, :updated_at)
json.(pin, :is_origin_domain_allowed)

json.url main_app.insight_url(pin)
