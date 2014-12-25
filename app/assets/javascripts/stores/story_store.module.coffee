# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')

ItemsCursor   = GlobalState.cursor(['stores', 'stories', 'items'])
CreateCursor  = GlobalState.cursor(['stores', 'stories', 'create'])

EmptyStories  = Immutable.Map()

SyncAPI       = require('sync/story_sync_api')


# Utils
#
UUID = require('utils/uuid')


fetchMany = (company_id, json) ->
  ItemsCursor.transaction()

  ItemsCursor.clear()

  Immutable.Seq(json.stories).forEach (story) ->
    ItemsCursor.set(story.uuid, story)

  ItemsCursor.commit()


# Handle Create
#

handleCreate = ->
  return if CreateCursor.deref(EmptyStories).size == 0
  
  # Cursor transaction
  # 
  GlobalState.cursor().transaction()
  
  
  CreateCursor.deref().forEach (item) ->
    beforeCreate  = item.getIn(['callbacks', 'beforeCreate'], ->)
    item          = item.remove('callbacks')
    itemUUID      = UUID()
    
    ItemsCursor.set(itemUUID, item)
    
    beforeCreate(itemUUID)
  

  # Clear cursor
  #
  CreateCursor.clear()
  

  # Cursor commit
  #
  GlobalState.cursor().commit()
  

GlobalState.addListener CreateCursor.path, handleCreate


# Dispatcher
#
Dispatcher.register (payload) ->
  
  if payload.action.type == 'company:fetch:done'
    fetchMany.apply(null, payload.action.data)


# Exports
#
module.exports =

  create: (attributes, callback = ->) ->
    SyncAPI.create(attributes.company_id, attributes)
      .done (json) ->
        SyncAPI.fetch(json.uuid)
          .done (json) ->
            ItemsCursor.set(json.story.uuid, json.story)
            setTimeout -> callback(json.story.uuid)
          .fail (xhr) ->
            callback()
      .fail (xhr) ->
        callback()
