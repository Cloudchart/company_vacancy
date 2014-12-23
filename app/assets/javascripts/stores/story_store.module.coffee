# Imports
#
Dispatcher = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')

ItemsCursor = GlobalState.cursor(['stores', 'stories', 'items'])

EmptyStories = Immutable.Map()


fetchMany = (company_id, json) ->
  ItemsCursor.transaction()

  ItemsCursor.clear()

  Immutable.Seq(json.stories).forEach (story) ->
    ItemsCursor.set(story.uuid, story)

  ItemsCursor.commit()



# Dispatcher
#
Dispatcher.register (payload) ->
  
  if payload.action.type == 'company:fetch:done'
    fetchMany.apply(null, payload.action.data)
