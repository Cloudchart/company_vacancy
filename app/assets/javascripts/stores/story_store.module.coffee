# Imports
#
GlobalState = require('global_state/state')


# Exports
#
module.exports = GlobalState.createStore

  displayName:    'StoryStore'

  collectionName: 'stories'
  instanceName:   'story'
  
  syncAPI:        require('sync/story_sync_api')
  
  serverActions: ->
    'post:fetch-all:done': @populate

  fetchAllByCompany: (company_id, options = {}) ->
    @syncAPI.fetchAllByCompany(company_id, options).then(@fetchDone, @fetcFail)

  createByCompany: (company_id, attributes = {}, options = {}) ->
    promise = @syncAPI.createByCompany(company_id, attributes, options)
    promise.then(@createDone, @createFail)
    promise
