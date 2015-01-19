# Pending promises
#
pendingPromises = {}


# Exports
#
module.exports =
  
  fetchAll: ->
  
  
  fetchOne: (id, force = false) ->
    delete pendingPromises['fetchOne' + id] if force == true

    pendingPromises['fetchOne' + id] ||= Promise.resolve $.ajax
      url:      '/pins/' + id
      dataType: 'json'
      cache:    false
  
  
  create: (attributes) ->
    Promise.resolve $.ajax
      url:      '/pins'
      type:     'POST'
      dataType: 'json'
      data:
        pin:    attributes
  
  
  update: ->
  
  
  destroy: (id) ->
    Promise.resolve $.ajax
      url:      '/pins/' + id
      type:     'DELETE'
      dataType: 'json'
