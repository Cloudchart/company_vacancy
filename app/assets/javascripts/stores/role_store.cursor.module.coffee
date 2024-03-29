# Imports
#
GlobalState = require('global_state/state')


# Exports
#
module.exports = GlobalState.createStore

  displayName:    'RoleStore'

  collectionName: 'roles'
  instanceName:   'role'

  syncAPI:        require('sync/role_sync_api')


  foreignKeys:
    'user':
      fields: 'user_id'

    'owner':
      fields: ['owner_id', 'owner_type']


  serverActions: ->
    'post:fetch-all:done': @populate


  filterForCompanies: ->
    @cursor.items.filter (role) ->
      role.get('owner_type') == 'Company'

  filterForUserCompanies: (user_id) ->
    @filterForCompanies().filter (role) -> role.get('user_id') == user_id

  # rolesFor: (id) ->
  #   @cursor.items
  #     .filter (item) ->
  #       item.get('user_id') == id

  rolesFor: (id) ->
    @byFK('user', id)


  # rolesOn: (id, type) ->
  #   @cursor.items.filter (role) ->
  #     role.get('owner_id')    == id and
  #     role.get('owner_type')  == type

  rolesOn: (id, type) ->
    @byFK('owner', id, type)


  # roles_on_owner_for_user: (owner, owner_type, user) ->
  #   @cursor.items.filterCursor (item) ->
  #     item.get('owner_id')    == owner.get('uuid')  and
  #     item.get('owner_type')  == owner_type         and
  #     item.get('user_id')     == user.get('uuid')

  rolesOnOwnerForUser: (owner_id, owner_type, user) ->
    @byFK('user', user.get('uuid'))
      .filter (item) ->
        item.get('owner_id')    == owner_id and
        item.get('owner_type')  == owner_type

  filterUserRoles: (user_id, owner_type=null) ->
    @byFK('user', user_id).filter (role) ->
      !owner_type || role.get('owner_type') == owner_type

  filterUserPinboards: (user_id) ->
    pinboards_ids = @filterUserRoles(user_id, 'Pinboard')
      .map (item) -> item.get('owner_id')

    PinboardStore = require('stores/pinboard_store')

    pinboards_ids.map (id) -> PinboardStore.get(id)

  isInvited: (owner_id, ownerType, user) ->
    (role = @rolesOnOwnerForUser(owner_id, ownerType, user)) && role.get('pending_value')

  accept: (item) ->
    @syncAPI.accept(item).then @updateDone, @updateFail
