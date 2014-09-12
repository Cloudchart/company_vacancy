# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
Constants   = require('cloud_blueprint/constants')


# Exports
#
module.exports =
  
  doneFetch: (key, json) ->
    Dispatcher.handleServerAction
      type:   Constants.Chart.DONE_FETCH_CHART
      key:    key
      json:   json
  
  
  failFetch: (key, xhr) ->
    Dispatcher.handleServerAction
      type:   Constants.Chart.FAIL_FETCH_CHART
      key:    key
      xhr:    xhr
      json:   xhr.responseJSON
