##= require dispatcher/dispatcher.module

Dispatcher = require('dispatcher/dispatcher')

# Exports
#
module.exports =
  
  # Fetch done
  #
  fetchDone: (json) ->
    json = [json] unless _.isArray[json]

    Dispatcher.handleServerAction
      type: 'person:fetch:done'
      json: json
  
  
  # Fetch fail
  #
  fetchFail: (xhr) ->
    Dispatcher.handleServerAction
      type: 'person:fetch:fail'
      xhr:  xhr
  

  # Update done
  #
  updateDone: (json) ->
    Dispatcher.handleServerAction
      type: 'person:update:done'
      json: json
    

  # Update fail
  #
  updateFail: (xhr) ->
    Dispatcher.handleServerAction
      type: 'person:update:fail'
      xhr:  xhr
