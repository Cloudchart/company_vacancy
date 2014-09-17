# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
Constants   = require('constants')


# Exports
#
module.exports =
  
  fetchDone: (json) ->
    Dispatcher.handleServerAction
      type: Constants.Token.FETCH_DONE
      json: json
  
  
  fetchFail: (xhr) ->
  
  
  createDone: (key, json) ->
    Dispatcher.handleServerAction
      type: Constants.Token.CREATE_DONE
      key:  key
      json: json
  
  
  createFail: (key, xhr) ->
    Dispatcher.handleServerAction
      type: Constants.Token.CREATE_FAIL
      key:  key
      json: xhr.responseJSON
      xhr:  xhr
  
  
  deleteDone: (key, json) ->
    Dispatcher.handleServerAction
      type: Constants.Token.DELETE_DONE
      key:  key
      json: json
