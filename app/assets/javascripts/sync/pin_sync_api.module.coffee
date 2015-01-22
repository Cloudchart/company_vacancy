# Pending promises
#
pendingPromises = {}


# Exports
#
module.exports =
  
  fetchAll: (options = {}, force = false) ->
    signature = '/pins' + JSON.stringify(Immutable.Seq(options).sortBy((v, k) -> k))
    
    delete pendingPromises[signature] if force == true
    
    pendingPromises[signature] ||= Promise.resolve $.ajax
      url:      '/pins'
      dataType: 'json'
      data:     options
  
  
  fetchOne: (id, options = {}, force = false) ->
    signature = '/pins/' + id + JSON.stringify(Immutable.Seq(options).sortBy((v, k) -> k))
    
    delete pendingPromises[signature] if force == true

    pendingPromises[signature] ||= Promise.resolve $.ajax
      url:      '/pins/' + id
      dataType: 'json'
      data:     options
  
  
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
