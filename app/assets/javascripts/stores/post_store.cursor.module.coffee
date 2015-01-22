# Imports
#

Dispatcher    = require('dispatcher/dispatcher')
GlobalState   = require('global_state/state')

Empty           = Immutable.Map()
ItemsCursor     = GlobalState.cursor(['stores', 'posts', 'items'])


# setDataFromJSON
#
setDataFromJSON = (json) ->
  Immutable.Seq(json.posts || [json.post]).forEach (item) -> ItemsCursor.set(item.uuid, item)


# Dispatcher
#
dispatchToken = Dispatcher.register (payload) ->
  type = payload.action.type
  
  switch type
    when 'fetch:done'
      [json] = payload.action.data
      setDataFromJSON(json) if json.post or json.posts


# Exports
#
module.exports =

  empty: Empty
  
  cursor:
    items:  ItemsCursor
