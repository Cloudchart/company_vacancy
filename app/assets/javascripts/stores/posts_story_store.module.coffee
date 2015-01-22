# Imports
# 
Dispatcher = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')

PostsStorySyncAPI = require('sync/posts_story_sync_api')

ItemsCursor = GlobalState.cursor(['stores', 'posts_story', 'items'])


# Dispatcher
# 
Dispatcher.register (payload) ->

  if payload.action.type is 'post:fetch-all:done'
    [json] = payload.action.data

    ItemsCursor.transaction()
    Immutable.Seq(json.posts_stories).forEach (posts_story) -> ItemsCursor.set(posts_story.uuid, posts_story)
    ItemsCursor.commit()    


# Create
#
createDone = (json) ->
  ItemsCursor.set(json.posts_story.uuid, json.posts_story)

createFail = (xhr) ->
  console.warn 'PostsStory createFail'


# Destroy
#
destroyDone = (json) ->
  ItemsCursor.remove(json.id)

destroyFail = (xhr) ->
  console.warn 'PostsStory destroyFail'


# Exports
# 
module.exports = 
  
  cursor:
    items: ItemsCursor

  findByPostAndStoryIds: (post_id, story_id) ->
    ItemsCursor.deref(Immutable.Map()).find (posts_story, key) =>
      posts_story.get('post_id') is post_id and posts_story.get('story_id') is story_id

  # CRUD
  # 
  create: (post_id, attributes = {}) ->
    promise = PostsStorySyncAPI.create(post_id, attributes)
    promise.then(createDone, createFail)
    promise


  destroy: (id) ->
    promise = PostsStorySyncAPI.destroy(id)
    promise.then(destroyDone, destroyFail)
    promise
