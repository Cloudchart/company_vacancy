json.(pinboard, :uuid, :user_id)
json.(pinboard, :title, :description, :position)
json.(pinboard, :access_rights)
json.(pinboard, :created_at, :updated_at)

json.readers_count pinboard.readers.size + pinboard.writers.size + pinboard.followers.size
json.pins_count pinboard.pins.size

json.url main_app::pinboard_url(pinboard)

json.users pinboard.users
json.tokens pinboard.invite_tokens
