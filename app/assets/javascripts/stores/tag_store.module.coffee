# Imports
#

Dispatcher  = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')


ItemsCursor = GlobalState.cursor(['stores', 'tags', 'items'])

# Exports
#
module.exports = GlobalState.createStore

  displayName:    'TagStore'

  collectionName: 'tags'
  instanceName:   'tag'
