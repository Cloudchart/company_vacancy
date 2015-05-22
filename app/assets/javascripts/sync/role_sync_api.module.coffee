module.exports =

  create: (attributes = {}, options = {}) ->
    # TODO fix godawful twitter passing

    Promise.resolve $.ajax
      url:      '/roles'
      type:     'POST'
      dataType: 'json'
      data:
        role:    _.omit(attributes, 'twitter')
        twitter: attributes.twitter

  update: (item, attributes = {}, options = {}) ->
    Promise.resolve $.ajax
      url:      '/roles/' + item.get('uuid')
      type:     'PUT'
      dataType: 'json'
      data:
        role: attributes

  fetchOne: (id, params = {}) ->
    Promise.resolve $.ajax
      url:      '/roles/' + id
      dataType: 'json'
      data:     params

  destroy: (item) ->
    Promise.resolve $.ajax
      url:      '/roles/' + item.get('uuid')
      type:     'DELETE'
      dataType: 'json'

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