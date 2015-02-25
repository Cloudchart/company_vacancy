Dispatcher  = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')


module.exports = GlobalState.createStore

  displayName:    'TokenStore'

  collectionName: 'tokens'
  instanceName:   'token'