# Imports
#

Dispatcher  = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')


ItemsCursor = GlobalState.cursor(['stores', 'tags', 'items'])
EmptyTags   = Immutable.Map()

Dispatcher.register (payload) ->
  
  if payload.action.type == 'company:fetch:done'
    [companyId, json] = payload.action.data
    
    ItemsCursor.update (data = EmptyTags) ->
      data.withMutations (data) ->
        Immutable.List(json.tags).forEach (tag) ->
          data.set(tag.uuid, Immutable.fromJS(tag))

# Exports
#
module.exports = GlobalState.createStore

  displayName:    'TagStore'

  collectionName: 'tags'
  instanceName:   'tag'
