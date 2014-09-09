# Imports
#
Dispatcher = require('dispatcher/dispatcher')


# Module
#
Module =
  
  fetchDone: (json) ->
    json = [json] unless _.isArray(json)
    
    Dispatcher.handleServerAction
      type: 'vacancy:fetch:done'
      json: json
  
  
  fetchFail: (xhr) ->
    Dispatcher.handleServerAction
      type: 'vacancy:fetch:fail'
      xhr:  xhr
      json: xhr.responseJSON
  
  
  # Create done
  #
  createDone: (model, json) ->
    Dispatcher.handleServerAction
      type:   'vacancy:create:done'
      model:  model
      json:   json
  
  
  # Create fail
  #
  createFail: (model, xhr) ->
    Dispatcher.handleServerAction
      type:   'vacancy:create:fail'
      model:  model
      xhr:    xhr
      json:   xhr.responseJSON


  # Update done
  #
  updateDone: (model, json) ->
    Dispatcher.handleServerAction
      type:   'vacancy:update:done'
      model:  model
      json:   json
  
  
  # Update fail
  #
  updateFail: (model, xhr) ->
    Dispatcher.handleServerAction
      type:   'vacancy:update:fail'
      model:  model
      xhr:    xhr
      json:   xhr.responseJSON


# Exports
#
module.exports = Module