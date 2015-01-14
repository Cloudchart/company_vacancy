# Imports
#

Dispatcher      = require('dispatcher/dispatcher')
PinboardSyncAPI = require('sync/pinboard_sync_api')
GlobalState     = require('global_state/state')


ItemsCursor = GlobalState.cursor(['stores', 'pinboards', 'items'])


EmptyPinboards = Immutable.Seq({})


# Dispatcher
#

Dispatcher.register (payload) ->
  
  if payload.action.type == 'pinboards:fetch:done'
    [json] = payload.action.data
    
    ItemsCursor.transaction()
    
    Immutable.Seq(json.pinboards).forEach (pinboard) ->
      ItemsCursor.set(pinboard.uuid, pinboard)
    
    ItemsCursor.commit()


  if payload.action.type == 'pinboard:fetch:done'
    [json] = payload.action.data
    
    ItemsCursor.set(json.pinboard.uuid, json.pinboard)


# Fetch
#
fetchAllDone = (json) ->
  Dispatcher.handleServerAction
    type: 'pinboards:fetch:done'
    data: [json]


fetchAllFail = (xhr) ->
  alert 'Error loading pinboards. Please, refresh the page.'
  

fetchOneDone = (json) ->
  Dispatcher.handleServerAction
    type: 'pinboard:fetch:done'
    data: [json]


fetchOneFail = (id) ->
  (xhr) ->
    console.warn 'PinboardStore: error fetching pinboard with id "' + id + '"'

# Create
#
createDone = (json) ->
  PinboardSyncAPI.fetchOne(json.id).then(fetchOneDone, fetchOneFail(json.id))


createFail = (xhr) ->
  alert 'Error creating pinboard. Please, try again later.'


# Update
#
updateDone = (json) ->
  PinboardSyncAPI.fetchOne(json.id).then(fetchOneDone, fetchOneFail(json.id))


updateFail = (xhr) ->
  alert 'Error updating pinboard. Please, try again later.'


# Destroy
#
destroyDone = (json) ->
  ItemsCursor.remove(json.id)


destroyFail = (xhr) ->
  alert 'Error deleting pinboard. Please, try again later.'


# Exports
#
module.exports =
  
  empty: EmptyPinboards

  fetchAll: ->
    PinboardSyncAPI.fetchAll().then(fetchAllDone, fetchAllFail)
  

  fetchOne: (id) ->
    PinboardSyncAPI.fetchOne(id).then(fetchOneDone, fetchOneFail(json.id))
  

  create: (title) ->
    PinboardSyncAPI.create({ title: title }).then(createDone, createFail)
  
  
  update: (id, title) ->
    PinboardSyncAPI.update(id, { title: title }).then(updateDone, updateFail)
  

  destroy: (id) ->
    PinboardSyncAPI.destroy(id).then(destroyDone, destroyFail)
