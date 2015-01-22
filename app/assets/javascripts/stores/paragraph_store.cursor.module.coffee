# Imports
#

Dispatcher    = require('dispatcher/dispatcher')
GlobalState   = require('global_state/state')

Empty           = Immutable.Map()
ItemsCursor     = GlobalState.cursor(['stores', 'paragraphs', 'items'])


# setDataFromJSON
#
setDataFromJSON = (json) ->
  Immutable.Seq(json.paragraphs || [json.paragraph]).forEach (item) -> ItemsCursor.set(item.uuid, item)


# Dispatcher
#
dispatchToken = Dispatcher.register (payload) ->
  type = payload.action.type
  
  switch type
    when 'fetch:done'
      [json] = payload.action.data
      setDataFromJSON(json) if json.paragraphs or json.paragraph


# Exports
#
module.exports =

  empty: Empty
  
  cursor:
    items:  ItemsCursor
