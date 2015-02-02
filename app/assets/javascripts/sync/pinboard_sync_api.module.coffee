# Pending promises
#
pendingPromises = {}


# Exports
#
module.exports =


  fetchAll: (params = {}, options = {}) ->
    delete pendingPromises['fetchAll'] if options.force == true

    pendingPromises['fetchAll'] ||= Promise.resolve $.ajax
      url:      '/pinboards'
      dataType: 'json'
      cache:    false
      data:     params


  fetchOne: (id, params = {}, options = {}) ->
    delete pendingPromises['fetchOne' + id] if options.force == true

    pendingPromises['fetchOne' + id] ||= Promise.resolve $.ajax
      url:        '/pinboards/' + id
      dataType:   'json'
      cache:      false
      data:       params


  create: (attributes = {}, options = {}) ->
    Promise.resolve $.ajax
      url:      '/pinboards'
      type:     'POST'
      dataType: 'json'
      data:
        pinboard: attributes


  update: (item, attributes = {}, options = {}) ->
    Promise.resolve $.ajax
      url:      '/pinboards/' + item.get('uuid')
      type:     'PUT'
      dataType: 'json'
      data:
        pinboard: attributes


  destroy: (id) ->
    Promise.resolve $.ajax
      url:      '/pinboards/' + id
      type:     'DELETE'
      dataType: 'json'
