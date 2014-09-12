# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
Constants   = require('cloud_blueprint/constants')


# Main
#

Store =


  noop: ->


# Handler
#
Store.dispatchToken = Dispatcher.register (payload) ->
  action = payload.action
  
  console.log action
  
  switch action.type
    
    when Constants.Chart.DONE_FETCH_CHART
      console.log 'chart loaded: ', action.key, ' ', action.json.uuid


# Exports
#
module.exports = Store
