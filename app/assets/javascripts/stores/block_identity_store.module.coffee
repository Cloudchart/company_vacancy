# Imports
#
GlobalState = require('global_state/state')


# Exports
#
module.exports = GlobalState.createStore

  displayName:    'BlockIdentityStore'

  collectionName: 'block_identities'
  instanceName:   'block_identity'


  filterForBlock: (id) ->
    @cursor.items.filter (item) ->
      item.get('block_id') == id
