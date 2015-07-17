GlobalState = require('global_state/state')


module.exports = GlobalState.createStore

  displayName:    'LandingStore'

  collectionName: 'landings'
  instanceName:   'landing'

  syncAPI:        require('sync/landing_sync_api')