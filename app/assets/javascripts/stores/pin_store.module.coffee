# Imports
#
GlobalState = require('global_state/state')


# Exports
#
module.exports = GlobalState.createStore
  
  displayName:    'PinStore'

  collectionName: 'pins'
  instanceName:   'pin'
  
  syncAPI:        require('sync/pin_sync_api')
  
  
  serverActions: ->
    'post:fetch-all:done': @populate


  filterByPinboardId: (pinboard_id) ->
    @cursor.items.deref(@empty).filter (item) -> item.get('pinboard_id') == pinboard_id

