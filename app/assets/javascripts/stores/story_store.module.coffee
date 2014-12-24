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

  itemUUID = UUID()
  data = CreateCursor.deref()
  
  ItemsCursor.set(itemUUID, data)

  CreateCursor.clear()

  GlobalState.cursor().commit()

  # Server action
  # 
  SyncAPI.create(data.get('company_id'), data.toJSON())
  

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
