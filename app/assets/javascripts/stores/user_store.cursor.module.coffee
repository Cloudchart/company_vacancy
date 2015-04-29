# Imports
#

GlobalState   = require('global_state/state')
ViewerQuery   = new GlobalState.query.Query("Viewer")

RoleStore = require('stores/role_store.cursor')


# waiting for shapers \_(@)_/
findSystemRoleForUser = (user, value) ->
  RoleStore.cursor.items
    .find (role) ->
      role.get('owner_id', null) is null and
      role.get('owner_type', null) is null and
      role.get('user_id') is user.get('uuid') and
      role.get('value') is value


# Exports
#
module.exports = GlobalState.createStore

  displayName:    'UserStore'


  collectionName: 'users'
  instanceName:   'user'


  syncAPI: require('sync/user_sync_api')


  serverActions: ->
    'post:fetch-all:done': @populate


  me: ->
    me = @cursor.items.cursor('me')

    GlobalState.fetch(ViewerQuery).then (json) =>
      @cursor.items.set('me', json.users[0]) unless me.deref()

    me


  unicorns: ->
    roles = RoleStore.cursor.items

    @cursor.items

      .filterCursor (user) ->
        roles.find (role) ->
          role.get('owner_type', null)  is null       and
          role.get('owner_id',   null)  is null       and
          role.get('value')             is 'unicorn'  and
          role.get('user_id')           is user.get('uuid')


  isAdmin: (user = null) ->
    user ||= @me()
    !!findSystemRoleForUser(user, 'admin')

  isEditor: (user = null) ->
    user ||= @me()
    !!findSystemRoleForUser(user, 'editor')

  isUnicorn: (user = null) ->
    user ||= @me()
    !!findSystemRoleForUser(user, 'unicorn')
