json.(landing, :uuid, :body)
json.(landing, :user_id, :author_id)

json.url main_app.landing_path(landing)
json.image_url landing.image.thumb('512x512>').url if landing.image_stored?