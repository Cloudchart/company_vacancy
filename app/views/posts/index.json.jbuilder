json.posts ams(@posts, scope: current_user)
json.blocks ams(@blocks)
json.pictures ams(@pictures)
json.paragraphs ams(@paragraphs)
json.visibilities ams(@visibilities)
json.stories ams(@stories, scope: @company)
json.posts_stories ams(@posts_stories)


# Pins
#

json.pins @pins do |pin|
  json.partial! 'pin', pin: pin
end

# Users
#
users = @pins.map(&:user).compact.uniq

json.users users do |user|
  json.partial! 'user', user: user
end
