##= require ../dispatcher/dispatcher

# Imports
#
Dispatcher = cc.require('cc.Dispatcher')


# Creator
#
Creator =
  

  startSync: (id) ->
    Dispatcher.handleServerAction
      type: 'company:sync:start'
      data: id
  
  
  stopSync: (id) ->
    Dispatcher.handleServerAction
      type: 'company:sync:stop'
      data: id
    
  
  receiveAll: (json) ->
    Dispatcher.handleServerAction
      type: 'company:receive:all'
      data: json
  

  receiveOne: (json) ->
    Dispatcher.handleServerAction
      type: 'company:receive:one'
      data: json
  

# Exports
#
cc.module('cc.actions.CompanyActionsCreator').exports = Creator
