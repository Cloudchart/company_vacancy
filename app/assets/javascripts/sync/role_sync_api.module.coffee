module.exports =

  update: (item, attributes = {}, options = {}) ->
    Promise.resolve $.ajax
      url:      '/roles/' + item.get('uuid')
      type:     'PUT'
      dataType: 'json'
      data:
        role: attributes
