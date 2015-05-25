json.(pinboard, :uuid, :user_id)
json.(pinboard, :title, :description, :position)
json.(pinboard, :access_rights)
json.(pinboard, :created_at, :updated_at)
json.url collection_url(pinboard)

json.readers_count pinboard.readers.size + pinboard.writers.size + pinboard.followers.size
json.pins_count pinboard.pins.size
