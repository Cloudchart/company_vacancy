# Imports
#
GlobalState = require('global_state/state')


# Exports
#
module.exports = GlobalState.createStore
  
  displayName:    'UserStore'


  collectionName: 'users'
  instanceName:   'user'
  
  
  syncAPI: require('sync/user_sync_api')
  

  serverActions: ->
    'post:fetch-all:done': @populate
  
  
  fetchCurrentUser: (options = {}) ->
    @syncAPI.fetchCurrentUser(options).then(@fetchCurrentUserDone, @fetchFail)


  # TODO temp solution, need to decide where to put current user
  fetchCurrentUserDone: (json) ->
    GlobalState.cursor().set("current", json.user)
    @fetchDone(json)

  getCurrentUser: ->
    GlobalState.cursor().get("current")

  update: (params = {}, options = {}) ->
    promise = @syncAPI.update(params, options)
    promise.then(@updateDone, @updateFail)
    promise
  
  updateDone: (json) ->
    @fetchCurrentUser()

  updateFail: (json) ->