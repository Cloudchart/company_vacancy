stories = @company.posts.map { |post| post.stories }.flatten.uniq
posts = @company.posts.select { |post| post.stories.any? }
posts_stories = @company.posts.map { |post| post.posts_stories }.flatten
pins = @company.posts.map { |post| post.pins }.flatten

json.stories ams(stories, scope: @company)
json.posts ams(posts, scope: current_user)
json.posts_stories ams(posts_stories)
json.pins ams(pins)
