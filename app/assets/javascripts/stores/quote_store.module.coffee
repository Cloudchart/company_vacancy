GlobalState = require('global_state/state')


# Exports
#
module.exports = GlobalState.createStore

  displayName:    'QuoteStore'

  collectionName: 'quotes'
  instanceName:   'quote'

  syncAPI:        require('sync/quote_sync_api')

  serverActions: ->
    'post:fetch-all:done': @populate


  findByBlock: (block_id) ->
    @findByOwner(type: 'Block', id: block_id)


  findByOwner: (owner) ->
    @cursor.items.find (item) ->
      item.get('owner_id')    == owner.id and
      item.get('owner_type')  == owner.type
