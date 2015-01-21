# Exports
#
module.exports =
  
  # create: (attributes) ->
  #   Promise.resolve $.ajax
  #     url:      '/pins'
  #     type:     'POST'
  #     dataType: 'json'
  #     data:
  #       pin:    attributes
  
  
  # update: ->
  
  
  destroy: (id) ->
    Promise.resolve $.ajax
      url:      '/posts_stories/' + id
      type:     'DELETE'
      dataType: 'json'
