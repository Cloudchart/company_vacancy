# Imports
#
GlobalState = require('global_state/state')


# Exports
#
module.exports = GlobalState.createStore
  
  displayName:    'UserStore'


  collectionName: 'users'
  instanceName:   'user'
  

  serverActions: ->
    'post:fetch-all:done': @populate
