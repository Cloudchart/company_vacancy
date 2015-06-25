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

json.url main_app.collection_url(pinboard)

json.users begin
  preload_associations(siblings, cache, :users)

  pinboard.users
end

json.tokens begin
  preload_associations(siblings, cache, :tokens)

  pinboard.invite_tokens
end

json_edge! json, :facebook_share_url, edges do
  facebook_share_url(main_app.collection_url(pinboard))
end

json_edge! json, :twitter_share_url, edges do
  twitter_share_url(main_app.collection_url(pinboard))

json_edge! json, :pins_ids, edges do
  preload_associations(siblings, cache, :pins)
  pinboard.pins.map(&:id)
end


json_edge! json, :pins_count, edges do
  preload_associations(siblings, cache, :pins)
  pinboard.pins.size
end


json_edge! json, :readers_count, edges do
  preload_associations(siblings, cache, :readers, :writers, :followers)
  pinboard.readers.size + pinboard.writers.size + pinboard.followers.size
end


json_edge! json, :is_followed, edges do
  preload_associations(siblings, cache, :followers)
  pinboard.followers.map(&:user_id).include?(current_user.id)
end
