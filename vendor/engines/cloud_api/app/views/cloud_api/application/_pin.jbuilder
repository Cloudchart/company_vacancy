json.(pin, :uuid, :user_id, :parent_id, :pinboard_id)
json.(pin, :pinnable_id, :pinnable_type)
json.(pin, :content, :origin)
json.(pin, :pins_count, :weight)
json.(pin, :is_approved, :is_suggestion)
json.(pin, :created_at, :updated_at)

json.source_user_id pin.source(:user_id)

json_edge! json, :url, edges do
  main_app.insight_url(pin)
end

json_edge! json, :facebook_share_url, edges do
  facebook_share_url(main_app.insight_url(pin))
end

json_edge! json, :twitter_share_url, edges do
  content = pin.parent ? pin.parent.content : pin.content
  twitter_share_url(main_app.insight_url(pin), content)
end

json_edge! json, :context, edges do
  preload_associations(siblings, cache, post: :company)

  if pin.post.present? && pin.post.company.present?
    {
      post: {
        id:     pin.post.id,
        title:  pin.post.title,
        url:    main_app.post_url(pin.post)
      },
      company: {
        id:     pin.post.company.id,
        title:  pin.post.company.name,
        url:    main_app.company_url(pin.post.company)
      }
    }
  else
    {}
  end
end

json_edge! json, :is_origin_domain_allowed, edges do
  pin.is_origin_domain_allowed
end

json_edge! json, :is_followed, edges do
  preload_associations(siblings, cache, :followers)
  !!pin.followers.find { |f| f.user_id == current_user.id }
end

json_edge! json, :is_mine, edges do
  pin.user_id == current_user.id
end

json_edge! json, :diffbot_response_data, edges do
  preload_associations(siblings, cache, :diffbot_response)
  pin.diffbot_response.try(:data)
end

json_edge! json, :connected_collections_ids, edges do
  Pin.preload_connected_collections(siblings, cache)
  ability = scope[:current_user_ability]
  pin.connected_collections.select { |c| ability.can?(:read, c) }.compact.map(&:id)
end

json_edge! json, :is_editable, edges do
  Rails.logger.debug "USER: #{current_user.editor?} : #{pin.user.unicorn?}"
  current_user.editor? && pin.user.unicorn?
end
