module.exports =

  
  createBlock: (key, attributes, token = 'create') ->
    Dispatcher.handleClientAction
      type: 'block:create'
      data: [key, attributes, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'block:create:done'
        data: [key, attributes, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'block:create:fail'
        data: [key, attributes, xhr.responseJSON, xhr, token]
    
    SyncAPI.createBlock(attributes.owner_id, attributes, done, fail)
    
  
  repositionBlocks: (key, ids, token = 'reposition') ->
    Dispatcher.handleClientAction
      type: 'blocks:reposition'
      data: [key, ids, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: 'blocks:reposition:done'
        data: [key, ids, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'blocks:reposition:fail'
        data: [key, ids, xhr.responseJSON, xhr, token]
      
    SyncAPI.repositionBlocks(key, ids, done, fail)
