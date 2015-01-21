# Imports
# 
Dispatcher = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')

ItemsCursor = GlobalState.cursor(['stores', 'posts_story', 'items'])

EmptyCursor = Immutable.Map()

# Dispatcher
# 
Dispatcher.register (payload) ->

  if payload.action.type is 'post:fetch-all:done'
    ItemsCursor.transaction()
    ItemsCursor.clear()

    Immutable.Seq(payload.action.data[0].posts_stories).forEach (posts_story) -> ItemsCursor.set(posts_story.uuid, posts_story)

    ItemsCursor.commit()    

module.exports = 
  
  cursor:
    empty: EmptyCursor
    items: ItemsCursor
