# Imports
#
GlobalState = require('global_state/state')


# Exports
#
module.exports = GlobalState.createStore
  
  displayName:    'BlockStore'

  collectionName: 'blocks'
  instanceName:   'block'
