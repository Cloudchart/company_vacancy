# Imports
#

Dispatcher      = require('dispatcher/dispatcher')
PinboardSyncAPI = require('sync/pinboard_sync_api')
GlobalState     = require('global_state/state')


ItemsCursor = GlobalState.cursor(['stores', 'pinboards', 'items'])


EmptyPinboards = Immutable.Map({})


# Dispatcher
#

Dispatcher.register (payload) ->
  
  if payload.action.type == 'pinboard:fetch-all:done'
    [json] = payload.action.data
    
    ItemsCursor.transaction()
    
    ItemsCursor.update(-> EmptyPinboards)
    
    Immutable.Seq(json.pinboards).forEach (pinboard) ->
      ItemsCursor.set(pinboard.uuid, pinboard)
    
    ItemsCursor.commit()


  if payload.action.type == 'pinboard:fetch-one:done'
    [json] = payload.action.data
    
    ItemsCursor.set(json.pinboard.uuid, json.pinboard)


# Fetch
#
fetchAll = (force = false) ->
  PinboardSyncAPI.fetchAll(force).then(fetchAllDone, fetchAllFail)


fetchAllDone = (json) ->
  Dispatcher.handleServerAction
    type: 'pinboard:fetch-all:done'
    data: [json]


fetchAllFail = (xhr) ->
  alert 'Error loading pinboards. Please, refresh the page.'


fetchOne = (id, force = false) ->
  PinboardSyncAPI.fetchOne(id, force).then(fetchOneDone, fetchOneFail(id))
  

fetchOneDone = (json) ->
  Dispatcher.handleServerAction
    type: 'pinboard:fetch-one:done'
    data: [json]


fetchOneFail = (id) ->
  (xhr) ->
    'Error loading pinboard with id "' + id + '". Please, try again later.'


# Create
#
createDone = (json) ->
  fetchOne(json.id, true)


createFail = (xhr) ->
  alert 'Error creating pinboard. Please, try again later.'


# Update
#
updateDone = (json) ->
  fetchOne(json.id, true)


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
  

  cursor:
    items: ItemsCursor


  fetchAll: fetchAll
  

  fetchOne: fetchOne
  

  create: (title) ->
    PinboardSyncAPI.create({ title: title }).then(createDone, createFail)
  
  
  update: (id, title) ->
    PinboardSyncAPI.update(id, { title: title }).then(updateDone, updateFail)
  

  destroy: (id) ->
    PinboardSyncAPI.destroy(id).then(destroyDone, destroyFail)
