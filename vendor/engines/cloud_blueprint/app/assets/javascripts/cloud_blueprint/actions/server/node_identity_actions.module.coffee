# Imports
#

Dispatcher = require('dispatcher/dispatcher')


# Module
#
Module =
  

  # Fetch done
  #
  fetchDone: (json) ->
    json = [json] unless _.isArray(json)

    Dispatcher.handleServerAction
      type: 'node_identity:fetch:done'
      json: json
  
  
  # Fetch fail
  #
  fetchFail: (xhr) ->
    Dispatcher.handleServerAction
      type: 'node_identity:fetch:fail'
      xhr:  xhr
      json: xhr.responseJSON
  
  
  # Destroy done
  #
  destroyDone: (model, json) ->
    Dispatcher.handleServerAction
      type:   'node_identity:destroy:done'
      model:  model
      json:   json
  
  
  # Destroy fail
  #
  destroyFail: (model, xhr) ->
    Dispatcher.handleServerAction
      type:   'node_identity:destroy:fail'
      model:  model
      xhr:    xhr
      json:   xhr.responseJSON
  

# Exports
#
module.exports = Module
