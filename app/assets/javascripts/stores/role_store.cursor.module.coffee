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
