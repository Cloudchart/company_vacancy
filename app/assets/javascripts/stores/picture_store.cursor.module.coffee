# Imports
#
GlobalState = require('global_state/state')


# Exports
#
module.exports = GlobalState.createStore

  displayName:    'PictureStore'

  collectionName: 'pictures'
  instanceName:   'picture'


  findByOwner: (owner) ->
    @cursor.items.find (item) ->
      item.get('owner_type')  == owner.type and
      item.get('owner_id')    == owner.id
