# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')

ItemsCursor   = GlobalState.cursor(['stores', 'stories', 'items'])
CreateCursor  = GlobalState.cursor(['stores', 'stories', 'create'])
DeleteCursor  = GlobalState.cursor(['stores', 'stories', 'delete'])

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
    
    # SyncAPI.create(item.get('company_id'), item.toJSON())
    #
    #   .done (newItemId) ->
    #
    #     SyncAPI.fetch(newItemId)
    #
    #       .done (json) ->
    #         ItemCursor.transaction()
    #         ItemCursor.remove(itemUUID)
    #         ItemCursor.set(json.story.uuid, json.story)
    #         ItemCursor.commit()
    #         callback(json.story.uuid) if typeof callback == 'function'
    #
    #       .fail (xhr) ->
    #         ItemCursor.remove(itemUUID)
    #
    #   .fail (xhr) ->
    #     ItemCursor.remove(itemUUID)
  

  # Clear cursor
  #
  CreateCursor.clear()
  

  # Cursor commit
  #
  GlobalState.cursor().commit()

  # itemUUID = UUID()
  #
  # data = CreateCursor.deref()
  #
  # ItemsCursor.set(itemUUID, data)
  #
  # CreateCursor.clear()
  #
  # GlobalState.cursor().commit()
  #
  # # Server action
  # #
  # SyncAPI.create(data.get('company_id'), data.toJSON())
  

GlobalState.addListener CreateCursor.path, handleCreate


# Handle Delete
#
handleDelete = ->
  return if DeleteCursor.deref(EmptyStories).size == 0
  
  GlobalState.cursor().transaction()

  ItemsCursor.remove(DeleteCursor.get('uuid'))

  DeleteCursor.clear()

  GlobalState.cursor().commit()


GlobalState.addListener DeleteCursor.path, handleDelete


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
