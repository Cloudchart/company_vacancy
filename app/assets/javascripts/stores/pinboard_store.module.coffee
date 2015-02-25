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


pinboardRolesFilter = (id, value) ->
  (item) ->
    item.get('owner_id')    == id         and
    item.get('owner_type')  == 'Pinboard' and
    item.get('value')       == value


# Exports
#
module.exports = GlobalState.createStore

  displayName: 'PinboardStore'

  collectionName: 'pinboards'
  instanceName:   'pinboard'

  syncAPI:        require('sync/pinboard_sync_api')


  readable_pinboards: (user) ->
    @cursor.items.filterCursor readablePinboardsFilter(user)


  writableBy: (id) ->
    roles         = RoleStore.rolesFor(id).filter((item) -> item.get('owner_type') == 'Pinboard' and item.get('value') == 'editor')
    pinboard_ids  = roles.map((item) -> item.get('owner_id')).valueSeq()

    @cursor.items
      .filter (item) -> item.get('user_id') == id
      .concat @cursor.items.filter (item) -> pinboard_ids.contains(item.get('uuid'))


  system: ->
    @cursor.items
      .filter (item) ->
        item.get('user_id', null) == null


  editorsFor: (id) ->
    filterUsersForRole(id, 'editor')


  readersFor: (id) ->
    filterUsersForRole(id, 'reader')


  followersFor: (id) ->
    filterUsersForRole(id, 'follower')
