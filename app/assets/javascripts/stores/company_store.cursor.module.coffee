# Imports
#

Dispatcher    = require('dispatcher/dispatcher')
GlobalState   = require('global_state/state')

EmptyCompanies  = Immutable.Map()
ItemsCursor     = GlobalState.cursor(['stores', 'companies', 'items'])


# setDataFromJSON
#
setDataFromJSON = (json) ->
  Immutable.Seq(json.companies || [json.company]).forEach (item) -> ItemsCursor.set(item.uuid, item)


# Dispatcher
#
dispatchToken = Dispatcher.register (payload) ->
  type = payload.action.type
  
  switch type
    when 'fetch:done'
      [json] = payload.action.data
      setDataFromJSON(json) if json.company or json.companies


# Exports
#
module.exports =

  empty: EmptyCompanies
  
  cursor:
    items:  ItemsCursor
