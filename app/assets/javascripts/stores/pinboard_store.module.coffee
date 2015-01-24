# Imports
#

Dispatcher      = require('dispatcher/dispatcher')
PinboardSyncAPI = require('sync/pinboard_sync_api')
GlobalState     = require('global_state/state')


ItemsCursor = GlobalState.cursor(['stores', 'pinboards', 'items'])


EmptyPinboards = Immutable.Map({})


# Set Data from JSON
#
setDataFromJSON = (json) ->
  Immutable.Seq(json.pinboards || [json.pinboard]).forEach (item) -> ItemsCursor.set(item.uuid, item)


# Dispatcher
#

dispatchToken = Dispatcher.register (payload) ->
  
  if payload.action.type == 'fetch:done'
    [json] = payload.action.data
    setDataFromJSON(json) if json.pinboards or json.pinboard
  

# Fetch
#
fetchAll = (force = false) ->
  promise = PinboardSyncAPI.fetchAll(force)
  promise.then(fetchDone, fetchAllFail)
  promise


fetchAllFail = (xhr) ->
  alert 'Error loading pinboards. Please, refresh the page.'


fetchOne = (id, force = false) ->
  PinboardSyncAPI.fetchOne(id, force).then(fetchDone, fetchOneFail(id))
  

fetchDone = (json) ->
  ItemsCursor.transaction()

  Dispatcher.handleServerAction
    type: 'fetch:done'
    data: [json]
  
  ItemsCursor.commit()


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


updateFail = (id, xhr) ->
  ItemsCursor.removeIn([id, '--sync--'])


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
  
  
  dispatchToken: dispatchToken


  fetchAll: fetchAll
  

  fetchOne: fetchOne
  

  create: (title) ->
    PinboardSyncAPI.create({ title: title }).then(createDone, createFail)
  
  
  update: (id, attributes = {}, options = {}) ->
    currItem = ItemsCursor.get(id)
    
    ItemsCursor.set(currItem.get('uuid'), currItem.set('--sync--', true))

    promise = PinboardSyncAPI.update(currItem, attributes, options)
    promise.then(updateDone, updateFail.bind(null, id))
    promise
  

  destroy: (id) ->
    PinboardSyncAPI.destroy(id).then(destroyDone, destroyFail)
