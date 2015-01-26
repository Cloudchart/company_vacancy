# Pending promises
#
pendingPromises = {}


# Exports
#
module.exports =
  
  fetchAll: (force = false) ->
    delete pendingPromises['fetchAll'] if force == true

    pendingPromises['fetchAll'] ||= Promise.resolve $.ajax
      url:      '/pinboards'
      dataType: 'json'
      cache:    false
  
  
  fetchOne: (id, force = false) ->
    delete pendingPromises['fetchOne' + id] if force == true

    pendingPromises['fetchOne' + id] ||= Promise.resolve $.ajax
      url:      '/pinboards/' + id
      dataType: 'json'
      cache:    false
  

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
