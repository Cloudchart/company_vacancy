# Imports
#
GlobalState = require('global_state/state')


# Exports
#
module.exports = GlobalState.createStore

  displayName:    'PostStore'

  collectionName: 'posts'
  instanceName:   'post'

  syncAPI:        require('sync/post_sync_api')
