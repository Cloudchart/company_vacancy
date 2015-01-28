identities  = {}


stories  = @company.posts.map { |post| post.stories }.flatten.uniq

identities[:posts]          = @company.posts.select { |post| post.stories.any? }
identities[:posts_stories]  = @company.posts.map    { |post| post.posts_stories }.flatten
identities[:pins]           = @company.posts.map    { |post| post.pins }.flatten


json.stories stories do |story|
  json.partial! 'story', story: story, company: @company
end

identities.each do |key, values|
  identity_name = key.to_s.singularize
  json.set! key, values do |value|
    json.partial! identity_name, :"#{identity_name}" => value
  end
end
