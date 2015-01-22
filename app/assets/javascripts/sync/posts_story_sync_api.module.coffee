# Exports
#
module.exports =
  
  create: (post_id, attributes) ->
    Promise.resolve $.ajax
      url:      "/posts/#{post_id}/posts_stories"
      type:     'POST'
      dataType: 'json'
      data:
        posts_story: attributes
  
  # update: ->
  
  destroy: (id) ->
    Promise.resolve $.ajax
      url:      "/posts_stories/#{id}"
      type:     'DELETE'
      dataType: 'json'
