# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
Constants   = require('constants')


# Data
#
data = new Immutable.Map({})


# Store
#
Store =
  

  find: (predicate) ->
  
  
  add: (json) ->
    


# Dispatcher
#
Store.dispatchToken = Dispatcher.register (payload) ->
  action = payload.action
  
  switch action.type
    when Constants.Company.COMPANY_FETCH_DONE
      _.noop


# Exports
#
module.exports = Store
