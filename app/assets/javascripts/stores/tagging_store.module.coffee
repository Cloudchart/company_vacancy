# Imports
#

Dispatcher  = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')


ItemsCursor = GlobalState.cursor(['stores', 'taggings', 'items'])


# Exports
#
module.exports = GlobalState.createStore

  displayName:    'TaggingStore'

  collectionName: 'taggings'
  instanceName:   'tagging'