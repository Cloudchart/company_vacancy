json.(pin, :uuid, :user_id, :parent_id, :pinboard_id, :author_id)
json.(pin, :pinnable_id, :pinnable_type)
json.(pin, :content, :origin)
json.(pin, :pins_count, :weight)
json.(pin, :is_approved, :is_suggestion)
json.(pin, :created_at, :updated_at)

json.insight_url  main_app.insight_url(pin)

json.is_featured begin
  preload_associations(siblings, cache, :feature)
  pin.is_featured?
end
