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
    @cursor.items.find (quote) -> quote.get("owner_id") == block_id && quote.get("owner_type") == "Block"


  findByPerson: (person_id) ->
    @cursor.items.find (quote) -> quote.get("person_id") == person_id