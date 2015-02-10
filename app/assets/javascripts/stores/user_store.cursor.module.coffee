# Imports
#
GlobalState   = require('global_state/state')


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

    GlobalState.fetch({ model: 'Viewer', relations: '' }).then (json) =>
      @cursor.items.set('me', json.users[0]) unless me.deref()

    me



  unicorns: ->
    roles = require('stores/role_store.cursor').cursor.items

    @cursor.items

      .filterCursor (user) ->
        roles.find (role) ->
          role.get('owner_type', null)  is null       and
          role.get('owner_id', null)    is null       and
          role.get('value')             is 'unicorn'  and
          role.get('user_id')           is user.get('uuid')
