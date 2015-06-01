json.(pin, :uuid, :user_id, :parent_id, :pinboard_id, :author_id)
json.(pin, :pinnable_id, :pinnable_type)
json.(pin, :content, :origin)
json.(pin, :pins_count, :weight)
json.(pin, :is_approved, :is_suggestion)
json.(pin, :created_at, :updated_at)

json.is_featured begin
  preload_association(siblings, :feature, cache)

  pin.featured?
end
