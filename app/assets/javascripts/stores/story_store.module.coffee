# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')

SyncAPI       = require('sync/story_sync_api')

ItemsCursor   = GlobalState.cursor(['stores', 'stories', 'items'])
CreateCursor  = GlobalState.cursor(['stores', 'stories', 'create'])

EmptyStories  = Immutable.Map()


# Dispatcher
# 
Dispatcher.register (payload) ->
  
  if payload.action.type == 'company:fetch:done'
    fetchMany.apply(null, payload.action.data)


# Utils
#
UUID = require('utils/uuid')


# Helpers
# 
setStoryItem = (uuid, story) ->
  story.name = story.name.replace(/_/g, ' ')
  ItemsCursor.set(uuid, story)


# Handlers
# 
fetchMany = (company_id, json) ->
  ItemsCursor.transaction()

  ItemsCursor.clear()

  Immutable.Seq(json.stories).forEach (story) -> setStoryItem(story.uuid, story)

  ItemsCursor.commit()


handleCreate = ->
  return if CreateCursor.deref(EmptyStories).size == 0
  
  # transaction
  GlobalState.cursor().transaction()
    
  CreateCursor.deref().forEach (item) ->
    beforeCreate  = item.getIn(['callbacks', 'beforeCreate'], ->)
    item          = item.remove('callbacks')
    itemUUID      = UUID()
    
    setStoryItem(itemUUID, item)
    
    beforeCreate(itemUUID)
  
  # clear cursor
  CreateCursor.clear()  

  # commit cursor
  GlobalState.cursor().commit()
  

GlobalState.addListener CreateCursor.path, handleCreate


# Exports
#
module.exports =

  create: (attributes, callback = ->) ->
    SyncAPI.create(attributes.company_id, attributes)
      .done (json) ->
        SyncAPI.fetch(json.uuid)
          .done (json) ->
            setStoryItem(json.story.uuid, json.story)
            setTimeout -> callback(json.story.uuid)
          .fail (xhr) ->
            callback()
      .fail (xhr) ->
        callback()
