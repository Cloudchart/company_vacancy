# Imports
#

Dispatcher    = require('dispatcher/dispatcher')
PinSyncAPI    = require('sync/pin_sync_api')
GlobalState   = require('global_state/state')


ItemsCursor = GlobalState.cursor(['stores', 'pins', 'items'])


EmptyPins   = Immutable.Map({})


# Dispatcher
#
Dispatcher.register (payload) ->
  
  type = payload.action.type
  
  switch type
    when 'pin:fetch-all:done', 'post:fetch-all:done'
      [json] = payload.action.data

      ItemsCursor.transaction()
      Immutable.Seq(json.pins).forEach (pin) -> ItemsCursor.set(pin.uuid, pin)
      ItemsCursor.commit()
      
    
    when 'pin:fetch-one:done'
      [json] = payload.action.data
      
      ItemsCursor.set(json.pin.uuid, json.pin)


# Fetch
#

fetchAll = (force = false) ->
  PinSyncAPI.fetchAll(force).then(fetchAllDone, fetchAllFail)


fetchOne = (id, force = false) ->
  PinSyncAPI.fetchOne(id, force).then(fetchOneDone, fetchOneFail)


fetchAllDone = (json) ->
  Dispatcher.handleServerAction
    type: 'pin:fetch-all:done'
    data: [json]


fetchAllFail = (xhr) ->
  Dispatcher.handleServerAction
    type: 'pin:fetch-all:fail'
    data: [xhr, xhr.responseJSON]
  

fetchOneDone = (json) ->
  Dispatcher.handleServerAction
    type: 'pin:fetch-one:done'
    data: [json]


fetchOneFail = (xhr) ->
  Dispatcher.handleServerAction
    type: 'pin:fetch-one:fail'
    data: [xhr, xhr.responseJSON]
  

# Create
#
createDone = (json) ->
  fetchOne(json.id, true)


createFail = (xhr) ->


# Destroy
#
destroyDone = (json) ->
  ItemsCursor.remove(json.id)


destroyFail = (xhr) ->
  
  


# Exports
#
module.exports =
  
  empty: EmptyPins

  cursor:
    items:  ItemsCursor
  
  
  fetchAll: fetchAll
  
  
  create: (attributes = {}) ->
    promise = PinSyncAPI.create(attributes)
    promise.then(createDone, createFail)
    promise


  destroy: (id) ->
    promise = PinSyncAPI.destroy(id)
    promise.then(destroyDone, destroyFail)
    promise