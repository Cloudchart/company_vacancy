# Imports
#
GlobalState = require('global_state/state')


# Exports
#
module.exports = GlobalState.createStore

  displayName:    'RoleStore'

  collectionName: 'roles'
  instanceName:   'role'


  rolesFor: (id) ->
    roles = require('stores/role_store.cursor').cursor.items

    roles.filter (role) -> role.get('user_id') is id


  roles_on_owner_for_user: (owner, owner_type, user) ->
    @cursor.items.filterCursor (item) ->
      item.get('owner_id')    == owner.get('uuid')  and
      item.get('owner_type')  == owner_type         and
      item.get('user_id')     == user.get('uuid')
