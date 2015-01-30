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


  currentUserCursor: ->
    currentUserCursor = @cursor.items.cursor([CurrentUserId])

    if CurrentUserId and !currentUserCursor.get('uuid')
      @fetchCurrentUser()

    currentUserCursor


  fetchCurrentUser: (options = {}) ->
    promise = @syncAPI.fetchCurrentUser(options)
    promise.then(@fetchDone, @fetchFail)
    promise
