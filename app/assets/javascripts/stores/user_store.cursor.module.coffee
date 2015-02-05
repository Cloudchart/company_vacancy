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


  me: (attribute) ->
    me = @cursor.items.get(CurrentUserId)
    if attribute then me.get(attribute) else me


  unicorns: ->
    roles = require('stores/role_store.cursor').cursor.items

    @cursor.items

      .filter (user) ->
        roles.find (role) ->
          role.get('owner_type', null)  is null       and
          role.get('owner_id', null)    is null       and
          role.get('value')             is 'unicorn'  and
          role.get('user_id')           is user.get('uuid')

      .valueSeq()


  currentUserCursor: ->
    currentUserCursor = @cursor.items.cursor([CurrentUserId])

    if CurrentUserId and !currentUserCursor.get('uuid')
      @fetchCurrentUser()

    currentUserCursor


  fetchCurrentUser: (options = {}) ->
    promise = @syncAPI.fetchCurrentUser(options)
    promise.then(@fetchDone, @fetchFail)
    promise
