json.(pinboard, :uuid, :user_id)
json.(pinboard, :title, :description, :position)
json.(pinboard, :access_rights, :is_important)
json.(pinboard, :created_at, :updated_at)

#json.readers_count pinboard.readers.size + pinboard.writers.size + pinboard.followers.size

json.readers_count begin
  preload_association(siblings, :readers, cache)
  preload_association(siblings, :writers, cache)
  preload_association(siblings, :followers, cache)

  pinboard.readers.size + pinboard.writers.size + pinboard.followers.size
end

json.pins_count begin
  preload_association(siblings, :pins, cache)

  pinboard.pins.size
end

json.url main_app::collection_url(pinboard)

json.users begin
  preload_association(siblings, :users, cache)

  pinboard.users
end

json.tokens begin
  preload_association(siblings, :tokens, cache)

  pinboard.invite_tokens
end
