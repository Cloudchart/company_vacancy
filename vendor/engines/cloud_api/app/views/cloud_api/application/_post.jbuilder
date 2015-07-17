json.(post, :uuid)
json.(post, :owner_id, :owner_type)
json.(post, :title)
json.(post, :created_at, :updated_at)

json.post_url main_app.post_path(post)

json.effective_from post.effective_from.try(:to_date)
json.effective_till post.effective_till.try(:to_date)
