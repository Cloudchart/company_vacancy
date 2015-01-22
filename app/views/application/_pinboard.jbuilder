json.(pinboard, :uuid, :user_id)
json.(pinboard, :title, :position)
json.(pinboard, :created_at, :updated_at)
json.url pinboard_url(pinboard)