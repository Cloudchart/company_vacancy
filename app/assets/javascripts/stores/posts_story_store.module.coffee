# Imports
# 
Dispatcher = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')

ItemsCursor = GlobalState.cursor(['stores', 'posts_story', 'items'])


# Dispatcher
# 
Dispatcher.register (payload) ->

  if payload.action.type is 'post:fetch-all:done'
    [json] = payload.action.data

    ItemsCursor.transaction()
    Immutable.Seq(json.posts_stories).forEach (posts_story) -> ItemsCursor.set(posts_story.uuid, posts_story)
    ItemsCursor.commit()    


# Destroy
#
destroyDone = (json) ->
  ItemsCursor.remove(json.id)

# destroyFail = (xhr) ->


# Exports
# 
module.exports = 
  
  cursor:
    items: ItemsCursor

  destroy: (id) ->
    promise = PostsStorySyncAPI.destroy(id)
    promise.then(destroyDone, destroyFail)
    promise
