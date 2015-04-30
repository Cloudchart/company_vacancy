# set posts
posts = @company.posts.includes(:visibilities, :pictures, :paragraphs, :quotes, :stories, :posts_stories, blocks: :block_identities, pins: [:pinboard, user: [:unicorn_role, :emails], parent: [user: [:unicorn_role, :emails] ] ])

# reject posts based on visibility rules
posts = if can?(:update, @company)
  posts
elsif can?(:finance, @company)
  posts.reject { |post| post.visibility.try(:value) == 'only_me' }
else
  posts.reject { |post| post.visibility.try(:value) =~ /only_me|trusted/ }
end

# set dependent collections
blocks = posts.map(&:blocks).flatten.concat(@company.blocks)
pictures = posts.map(&:pictures).flatten
paragraphs = posts.map(&:paragraphs).flatten
quotes = posts.map(&:quotes).flatten
visibilities = posts.map(&:visibilities).flatten
pins = posts.map(&:pins).flatten.reject { |pin| cannot?(:read, pin) }
stories = Story.cc_plus_company(@company.id)
posts_stories = posts.map(&:posts_stories).flatten
users = pins.map(&:user).compact.uniq
pinboards = pins.map(&:pinboard).compact.uniq
roles = users.map(&:unicorn_role).compact

# return json
json.posts ams(posts, scope: current_user)
json.blocks ams(blocks)
json.pictures ams(pictures)
json.paragraphs ams(paragraphs)

json.visibilities ams(visibilities)
json.stories ams(stories, scope: @company)
json.posts_stories ams(posts_stories)

json.quotes quotes do |quote|
  json.partial! 'quote', quote: quote
end

json.pins pins do |pin|
  json.partial! 'pin', pin: pin
end

json.pinboards pinboards do |pinboard|
  json.partial! 'pinboard', pinboard: pinboard
end

json.users users do |user|
  json.partial! 'user', user: user
end

json.roles roles do |role|
  json.partial! 'role', role: role
end
