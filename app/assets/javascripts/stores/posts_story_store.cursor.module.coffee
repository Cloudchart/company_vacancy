# Imports
#
GlobalState = require('global_state/state')


# Exports
#
module.exports = GlobalState.createStore

  displayName:    'PostsStoryStore'

  collectionName: 'posts_stories'
  instanceName:   'posts_story'

  serverActions: ->
    'post:fetch-all:done': @populate
