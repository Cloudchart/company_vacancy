# Imports
#
GlobalState   = require('global_state/state')


# Current User Id
#
CurrentUserId = try document.querySelector('meta[name="user-id"]').getAttribute('content') catch


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
    @cursor.items.cursor(CurrentUserId)


  unicorns: ->
    roles = require('stores/role_store.cursor').cursor.items

    @cursor.items

      .filterCursor (user) ->
        roles.find (role) ->
          role.get('owner_type', null)  is null       and
          role.get('owner_id', null)    is null       and
          role.get('value')             is 'unicorn'  and
          role.get('user_id')           is user.get('uuid')
