# set posts
posts = @company.posts.includes(:visibilities, :pictures, :paragraphs, :posts_stories, :quotes, blocks: :block_identities, pins: [ :user, parent: :user ])

# reject posts based on visibility rules
posts = if can?(:manage, @company)
  posts
elsif can?(:update, @company) || can?(:finance, @company)
  posts.reject { |post| post.visibility.try(:value) == 'only_me' }
else
  posts.reject { |post| post.visibility.try(:value) =~ /only_me|trusted/ }
end

# set dependent collections
blocks = posts.map(&:blocks).flatten
pictures = posts.map(&:pictures).flatten
paragraphs = posts.map(&:paragraphs).flatten
quotes = posts.map(&:quotes).flatten
visibilities = posts.map(&:visibilities).flatten
pins = posts.map(&:pins).flatten
stories = Story.cc_plus_company(@company.id)
posts_stories = posts.map(&:posts_stories).flatten
users = pins.map(&:user).compact.uniq

# return json
json.posts ams(posts, scope: current_user)
json.blocks ams(blocks)
json.pictures ams(pictures)
json.paragraphs ams(paragraphs)

json.quotes quotes do |quote|
  json.partial! 'quote', quote: quote
end

json.visibilities ams(visibilities)
json.stories ams(stories, scope: @company)
json.posts_stories ams(posts_stories)

json.pins pins do |pin|
  json.partial! 'pin', pin: pin
end

json.users users do |user|
  json.partial! 'user', user: user
end
