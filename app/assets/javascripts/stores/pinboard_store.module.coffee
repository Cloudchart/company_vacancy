# Imports
#
GlobalState = require('global_state/state')


# Stores
#
RoleStore = require('stores/role_store.cursor')
UserStore = require('stores/user_store.cursor')


# Utils
#
filterRoles = (id, value) ->
  RoleStore.cursor.items
    .filter (role) ->
      role.get('owner_id')    == id and
      role.get('owner_type')  == 'Pinboard' and
      role.get('value')       == value
    .valueSeq()


filterUsersForRole = (id, value) ->
  user_ids = filterRoles(id, value).map (role) -> role.get('user_id')

  UserStore.cursor.items
    .filter (user) ->
      user_ids.contains(user.get('uuid'))
    .valueSeq()


# Exports
#
module.exports = GlobalState.createStore

  displayName: 'PinboardStore'

  collectionName: 'pinboards'
  instanceName:   'pinboard'

  syncAPI:        require('sync/pinboard_sync_api')


  readable_pinboards: (user) ->
    @cursor.items.filterCursor readablePinboardsFilter(user)


  userCursorFor: (id) ->
    UserStore.cursor.items.cursor(@cursor.items.getIn([id, 'user_id']))


  editorsFor: (id) ->
    filterUsersForRole(id, 'editor')


  readersFor: (id) ->
    filterUsersForRole(id, 'reader')


  followersFor: (id) ->
    filterUsersForRole(id, 'follower')
