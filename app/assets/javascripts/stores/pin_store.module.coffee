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


  getParentFor: (id) ->
    @cursor.items.get(@cursor.items.getIn([id, 'parent_id']))


  getChildrenFor: (id) ->
    @cursor.items.filter (item) -> item.get('parent_id') == id


  filterByPinboardId: (pinboard_id) ->
    @cursor.items.deref(@empty).filter (item) -> item.get('pinboard_id') == pinboard_id

  filterByUserId: (user_id) ->
    @cursor.items.deref(@empty).filter (pin) -> pin.get('user_id') == user_id

  filterInsightsForPost: (post_id) ->
    @cursor.items
      .filter (item) ->
        item.get('pinnable_id')    == post_id  &&
        item.get('pinnable_type')  == 'Post'   &&
        ((!item.get('parent_id') && item.get('content')) || item.get('is_suggestion'))           

  filterPinsForPost: (post_id) ->
    @cursor.items
      .filter (item) ->
        item.get('pinnable_id')     is post_id  and
        item.get('pinnable_type')   is 'Post'   and
        (not item.get('parent_id') || item.get('is_suggestion'))
