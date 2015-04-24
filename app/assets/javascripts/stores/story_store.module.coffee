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

  createByCompany: (company_id, attributes = {}, options = {}) ->
    promise = @syncAPI.createByCompany(company_id, attributes, options)
    promise.then(@createDone, @createFail)
    promise
