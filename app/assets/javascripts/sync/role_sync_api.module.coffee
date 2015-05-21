module.exports =

  create: (attributes = {}, options = {}) ->
    Promise.resolve $.ajax
      url:      '/roles'
      type:     'PUT'
      dataType: 'json'
      data:
        role: attributes

  update: (item, attributes = {}, options = {}) ->
    Promise.resolve $.ajax
      url:      '/roles/' + item.get('uuid')
      type:     'PUT'
      dataType: 'json'
      data:
        role: attributes

  accept: (item) ->
    Promise.resolve $.ajax
      url:      '/roles/' + item.get('uuid') + '/accept'
      type:     'PATCH'
      dataType: 'json'

  decline: (item) ->
    Promise.resolve $.ajax
      url:      '/roles/' + item.get('uuid') + '/decline'
      type:     'PATCH'
      dataType: 'json'