json.(pinboard, :uuid, :user_id)
json.(pinboard, :title, :description, :position)
json.(pinboard, :access_rights, :is_important)
json.(pinboard, :created_at, :updated_at)

#json.readers_count pinboard.readers.size + pinboard.writers.size + pinboard.followers.size

json.readers_count begin
  preload_associations(siblings, cache, :readers, :writers, :followers)

  pinboard.readers.size + pinboard.writers.size + pinboard.followers.size
end

json.pins_count begin
  preload_associations(siblings, cache, :pins)

  pinboard.pins.size
end

json.url main_app::collection_url(pinboard)

json.users begin
  preload_associations(siblings, cache, :users)

  pinboard.users
end

json.tokens begin
  preload_associations(siblings, cache, :tokens)

  pinboard.invite_tokens
end
