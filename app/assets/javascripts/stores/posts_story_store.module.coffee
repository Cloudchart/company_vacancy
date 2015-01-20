# Imports
# 
Dispatcher = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')

ItemsCursor = GlobalState.cursor(['stores', 'posts_story', 'items'])

# Dispatcher
# 
Dispatcher.register (payload) ->
  
  if payload.action.type is 'post:fetch-all:done'
    ItemsCursor.transaction()
    ItemsCursor.clear()

    Immutable.Seq(json.posts_stories).forEach (posts_story) -> ItemsCursor.set(posts_story.uuid. posts_story)

    ItemsCursor.commit()    
