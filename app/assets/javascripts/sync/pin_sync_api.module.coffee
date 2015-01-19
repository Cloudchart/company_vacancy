# Pending promises
#
pendingPromises = {}


# Exports
#
module.exports =
  
  fetchAll: (options = {}) ->
    delete pendingPromises['fetchAll'] if options.force == true
    
    pendingPromises['fetchAll'] ||= Promise.resolve $.ajax
      url:      '/pins'
      dataType: 'json'
      cache:    false
      data:
        complete: options.complete
  
  
  fetchOne: (id, options = {}) ->
    delete pendingPromises['fetchOne' + id] if options.force == true

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
