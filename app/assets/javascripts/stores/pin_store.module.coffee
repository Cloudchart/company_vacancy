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


  filterInsightsForPost: (post_id) ->
    @cursor.items
      .filter (item) ->
        item.get('pinnable_id')     is post_id  and
        item.get('pinnable_type')   is 'Post'   and
        not item.get('parent_id')               and
        item.get('content')
