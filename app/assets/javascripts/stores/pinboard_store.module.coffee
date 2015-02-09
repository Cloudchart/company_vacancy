# Imports
#

Dispatcher      = require('dispatcher/dispatcher')
PinboardSyncAPI = require('sync/pinboard_sync_api')
GlobalState     = require('global_state/state')


RoleStore       = require('stores/role_store.cursor')


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
fetchAll = (params = {}, options = {}) ->
  promise = PinboardSyncAPI.fetchAll(params, options)
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


# Predicates
#

readablePinboardsFilter = (user) ->
  (item) ->
    roles = RoleStore.roles_on_owner_for_user(item, 'Pinboard', user)
      .map (role) -> role.get('value')

    item.get('access_rights') == 'public'           or
    item.get('user_id')       == user.get('uuid')   or
    roles.contains('editor')                        or
    roles.contains('reader')



# Exports
#
module.exports =

  empty: EmptyPinboards


  cursor:
    items: ItemsCursor


  has: (id) ->
    ItemsCursor.has(id)


  dispatchToken: dispatchToken


  fetchAll: fetchAll


  fetchOne: fetchOne


  readable_pinboards: (user) ->
    ItemsCursor.filterCursor readablePinboardsFilter(user)



  create: (attributes = {}, options ={}) ->
    promise = PinboardSyncAPI.create(attributes, options)
    promise.then(createDone, createFail)
    promise


  update: (id, attributes = {}, options = {}) ->
    currItem = ItemsCursor.get(id)

    ItemsCursor.set(currItem.get('uuid'), currItem.set('--sync--', true))

    promise = PinboardSyncAPI.update(currItem, attributes, options)
    promise.then(updateDone, updateFail.bind(null, id))
    promise


  destroy: (id) ->
    PinboardSyncAPI.destroy(id).then(destroyDone, destroyFail)
