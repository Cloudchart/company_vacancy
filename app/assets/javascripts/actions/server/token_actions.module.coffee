# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
Constants   = require('constants')


# Exports
#
module.exports =
  
  fetchDone: (token, json) ->
    Dispatcher.handleServerAction
      type:   Constants.Token.FETCH_DONE
      json:   json
      token:  token
  
  
  fetchFail: (token, xhr) ->
    Dispatcher.handleServerAction
      type:   Constants.Token.FETCH_FAIL
      json:   xhr.responseJSON
      token:  token
      xhr:    xhr
  
  
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
  
  
  updateDone: (key, json) ->
    Dispatcher.handleServerAction
      type: Constants.Token.UPDATE_DONE
      key:  key
      json: json
  
  
  updateFail: (key, xhr) ->
    Dispatcher.handleServerAction
      type: Constants.Token.UPDATE_FAIL
      key:  key
      json: xhr.responseJSON
      xhr:  xhr
  
  
  deleteDone: (key, json) ->
    Dispatcher.handleServerAction
      type: Constants.Token.DELETE_DONE
      key:  key
      json: json
