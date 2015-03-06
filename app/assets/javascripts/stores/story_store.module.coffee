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


# # Imports
# #
# Dispatcher  = require('dispatcher/dispatcher')
# GlobalState = require('global_state/state')
#
# SyncAPI       = require('sync/story_sync_api')
#
# ItemsCursor   = GlobalState.cursor(['stores', 'stories', 'items'])
# CreateCursor  = GlobalState.cursor(['stores', 'stories', 'create'])
#
# EmptyStories  = Immutable.Map()
#
#
# # Dispatcher
# #
# Dispatcher.register (payload) ->
#
#   switch payload.action.type
#     when 'post:fetch-all:done', 'stories:fetch-all:done'
#       populate.apply(null, payload.action.data)
#
#
# # Utils
# #
# UUID = require('utils/uuid')
#
#
# # Helpers
# #
# setStoryItem = (uuid, story) ->
#   story.name = story.name.replace(/_/g, ' ')
#   ItemsCursor.set(uuid, story)
#
#
# # Populate
# #
# populate = (json) ->
#   ItemsCursor.transaction()
#
#   ItemsCursor.clear()
#
#   Immutable.Seq(json.stories).forEach (story) -> setStoryItem(story.uuid, story)
#
#   ItemsCursor.commit()
#
#
# # Create
# #
# handleCreate = ->
#   return if CreateCursor.deref(EmptyStories).size == 0
#
#   # transaction
#   GlobalState.cursor().transaction()
#
#   CreateCursor.deref().forEach (item) ->
#     beforeCreate  = item.getIn(['callbacks', 'beforeCreate'], ->)
#     item          = item.remove('callbacks')
#     itemUUID      = UUID()
#
#     setStoryItem(itemUUID, item)
#
#     beforeCreate(itemUUID)
#
#   # clear cursor
#   CreateCursor.clear()
#
#   # commit cursor
#   GlobalState.cursor().commit()
#
# GlobalState.addListener CreateCursor.path, handleCreate
#
# # Update
# #
# updateDone = (json) ->
#   setStoryItem(json.story.uuid, json.story)
#
# updateFail = (prevItem, xhr) ->
#   console.warn 'Story updateFail'
#
#
# # Fetch
# #
# fetchDone = (json) ->
#   Dispatcher.handleServerAction
#     type: 'stories:fetch-all:done'
#     data: [json]
#
# fetchFail = (xhr) ->
#   console.warn('Stories fetchFail')
#
#
# # Exports
# #
# module.exports =
#
#   cursor:
#     empty: EmptyStories
#     items: ItemsCursor
#
#   fetchAll: (company_id) ->
#     promise = SyncAPI.fetchAll(company_id)
#     promise.then(fetchDone, fetchFail)
#     promise
#
#   create: (attributes, callback = ->) ->
#     SyncAPI.create(attributes.company_id, attributes)
#       .done (json) ->
#         SyncAPI.fetch(json.uuid)
#           .done (json) ->
#             setStoryItem(json.story.uuid, json.story)
#             setTimeout -> callback(json.story.uuid)
#           .fail (xhr) ->
#             callback()
#       .fail (xhr) ->
#         callback()
#
#   update: (id, attributes = {}) ->
#     promise = SyncAPI.update(id, attributes)
#     promise.then(updateDone, updateFail)
#     promise
