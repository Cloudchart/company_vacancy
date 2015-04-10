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

  serverActions: ->
    'post:fetch-all:done': @populate


  filterForCompanies: ->
    @cursor.items.filter (role) ->
      role.get('owner_type') == 'Company'

  filterForUserCompanies: (user_id) ->
    @filterForCompanies().filter (role) -> role.get('user_id') == user_id

  rolesFor: (id) ->
    @cursor.items
      .filter (item) ->
        item.get('user_id') == id


  rolesOn: (id, type) ->
    @cursor.items.filter (role) ->
      role.get('owner_id')    == id and
      role.get('owner_type')  == type


  roles_on_owner_for_user: (owner, owner_type, user) ->
    @cursor.items.filterCursor (item) ->
      item.get('owner_id')    == owner.get('uuid')  and
      item.get('owner_type')  == owner_type         and
      item.get('user_id')     == user.get('uuid')
