# Imports
#

Dispatcher    = require('dispatcher/dispatcher')
PinSyncAPI    = require('sync/pin_sync_api')
GlobalState   = require('global_state/state')


ItemsCursor = GlobalState.cursor(['stores', 'pins', 'items'])


EmptyPins   = Immutable.Map({})


# Set Data from JSON
#
setDataFromJSON = (json) ->
  Immutable.Seq(json.pins || [json.pin]).forEach (item) -> ItemsCursor.set(item.uuid, item)


# Dispatcher
#
Dispatcher.register (payload) ->
  
  type = payload.action.type
  
  switch type
    when 'fetch:done', 'post:fetch-all:done'
      [json] = payload.action.data
      setDataFromJSON(json) if json.pins or json.pin
      
    
# Fetch
#

fetchAll = (options = {}, force = false) ->
  promise = PinSyncAPI.fetchAll(options, force)
  promise.then(fetchDone, fetchAllFail)
  promise


fetchOne = (id, options = {}, force = false) ->
  promise = PinSyncAPI.fetchOne(id, options, force)
  promise.then(fetchDone, fetchOneFail)
  promise


fetchDone = (json) ->
  ItemsCursor.transaction()

  Dispatcher.handleServerAction
    type: 'fetch:done'
    data: [json]

  ItemsCursor.commit()


fetchAllFail = (xhr) ->
  Dispatcher.handleServerAction
    type: 'pin:fetch-all:fail'
    data: [xhr, xhr.responseJSON]
  

fetchOneFail = (xhr) ->
  Dispatcher.handleServerAction
    type: 'pin:fetch-one:fail'
    data: [xhr, xhr.responseJSON]
  

# Create
#
createDone = (json) ->
  fetchOne(json.id)


createFail = (xhr) ->


# Destroy
#
destroyDone = (json) ->
  ItemsCursor.transaction()
  ItemsCursor.remove(json.id)
  ItemsCursor.commit()


destroyFail = (xhr) ->
  
  


# Exports
#
module.exports =
  
  empty: EmptyPins

  cursor:
    items:  ItemsCursor
  
  
  fetchAll: fetchAll
  

  fetchOne: fetchOne
  
  
  filterByPinboardId: (pinboard_id) ->
    ItemsCursor.deref(EmptyPins)
      .filter (pin) -> pin.get('pinboard_id') == pinboard_id
      .sortBy (pin) -> pin.get('created_at')
      .reverse()
  
  
  create: (attributes = {}) ->
    promise = PinSyncAPI.create(attributes)
    promise.then(createDone, createFail)
    promise


  destroy: (id) ->
    promise = PinSyncAPI.destroy(id)
    promise.then(destroyDone, destroyFail)
    promise
