# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
BaseStore   = require('stores/base')


# Store
#
class Store extends BaseStore
  
  @displayName: 'NodeIdentityStore'



# Dispatch
#
Store.dispatchToken = Dispatcher.register (payload) ->
  action = payload.action
  
  switch action.type
    
    when 'node_identity:fetch:done'
      _.each action.json, (attributes) -> Store.add(new Store(attributes))
      Store.emitChange()
    
    
    when 'node_identity:create:done'
      action.model.attr(action.json)
      Store.add(action.model)
      Store.emitChange()
    
    
    when 'node_identity:destroy:done'
      Store.remove(action.model)
      Store.emitChange()
  

# Exports
#
module.exports = NodeIdentityStore = Store
