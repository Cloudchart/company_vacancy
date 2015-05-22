Dispatcher  = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')


module.exports = GlobalState.createStore

  displayName:    'TokenStore'

  collectionName: 'tokens'
  instanceName:   'token'

  syncAPI: require('sync/token_sync_api')

  filterInvites: (type) ->
    @cursor.items.filter (token) ->
      token.get('owner_type') == type &&
      token.get('name') == 'invite'

  filterCompanyInvites: ->
    @filterInvites('Company')

  findCompanyInvite: (company_id) ->
    @filterCompanyInvites().
      filter((token) => token.get('owner_id') == company_id).first()

  findByUserAndName: (user, name) ->
    @cursor.items.filter (token) ->
      token.get('owner_id') is user.get('uuid') and
      token.get('name') is name
    .first()

  createGreeting: (user, params = {}, options = {}) ->
    promise = @syncAPI.createGreeting(user, params, options)
    promise.then(@createDone, @createFail)
    promise

  createDone: (json) ->
    @fetchOne(json.id)

  updateGreeting: (id, params = {}, options = {}) ->
    promise = @syncAPI.updateGreeting(id, params, options)
    promise.then(@updateDone, @updateFail)
    promise

  updateDone: (json) ->
    @fetchOne(json.id, null, { force: true })

  destroyGreeting: (id, params = {}, options = {}) ->
    promise = @syncAPI.destroyGreeting(id, params, options)
    promise.then(@destroyDone, @destroyFail)
    promise

  destroyWelcomeTour: (id, params = {}, options = {}) ->
    promise = @syncAPI.destroyWelcomeTour(id, params, options)
    promise.then(@destroyDone, @destroyFail)
    promise

  destroyInsightTour: (id, params = {}, options = {}) ->
    promise = @syncAPI.destroyInsightTour(id, params, options)
    promise.then(@destroyDone, @destroyFail)
    promise

  destroyDone: (json) ->
    @remove(json.id)
