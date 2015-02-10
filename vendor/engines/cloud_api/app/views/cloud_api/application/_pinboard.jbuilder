json.(pinboard, :uuid, :user_id)
json.(pinboard, :title, :position)
json.(pinboard, :access_rights)
json.(pinboard, :created_at, :updated_at)

json.pins_count pinboard.pins.size

json.url main_app::pinboard_url(pinboard)
