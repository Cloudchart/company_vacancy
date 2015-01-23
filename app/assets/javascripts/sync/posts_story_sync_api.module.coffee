module.exports =
  
  create: (post_id, attributes) ->
    Promise.resolve $.ajax
      url:      "/posts/#{post_id}/posts_stories"
      type:     'POST'
      dataType: 'json'
      data:
        posts_story: attributes
  
  update: (id, attributes) ->
    Promise.resolve $.ajax
      url:      "/posts_stories/#{id}"
      type:     'PATCH'
      dataType: 'json'    
      data:
        posts_story: attributes
  
  destroy: (id) ->
    Promise.resolve $.ajax
      url:      "/posts_stories/#{id}"
      type:     'DELETE'
      dataType: 'json'
