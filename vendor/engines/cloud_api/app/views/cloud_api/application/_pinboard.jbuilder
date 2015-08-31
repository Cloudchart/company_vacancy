json.(pinboard, :uuid, :user_id)
json.(pinboard, :title, :description, :position)
json.(pinboard, :access_rights, :suggestion_rights)
json.(pinboard, :created_at, :updated_at)

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
end

json_edge! json, :pins_ids, edges do
  preload_associations(siblings, cache, :pins)
  pinboard.pins.map(&:id)
end

json_edge! json, :pins, edges do
  preload_associations(siblings, cache, :pins)
  pinboard.pins.map do |p|
    {
      id:         p.id,
      parent_id:  p.parent_id,
      is_insight: p.insight?
    }
  end
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

json_edge! json, :is_related, edges do
  preload_associations(siblings, cache, :readers, :writers, :followers)
  pinboard.user_id == current_user.id ||
  pinboard.writers.map(&:id).include?(current_user.id) ||
  pinboard.readers.map(&:id).include?(current_user.id) ||
  pinboard.followers.map(&:user_id).include?(current_user.id)
end

json_edge! json, :is_editable, edges do
  can?(:update, pinboard)
end

json_edge! json, :can_add_insight, edges do
  can?(:add_insight, pinboard)
end

json_edge! json, :is_invited, edges do
  preload_associations(siblings, cache, :roles)
  !!pinboard.roles.find { |pinboard| pinboard.user_id == current_user.id && pinboard.pending_value.present? }
end

json_edge! json, :features, edges do
  preload_associations(siblings, cache, :features)
  pinboard.features.map do |f|
    {
      id:     f.id,
      scope:  f.scope
    }
  end
end
