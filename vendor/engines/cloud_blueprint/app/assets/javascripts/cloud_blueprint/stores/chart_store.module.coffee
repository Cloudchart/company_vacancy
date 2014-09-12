# Imports
#
Dispatcher  = require('dispatcher/dispatcher')
Constants   = require('cloud_blueprint/constants')


data = new Immutable.Vector


# Main
#

Store =
  
  
  get: (key) ->
    data.find (item) -> item.get('uuid') == key
  

  #
  #
  GetElementForEmitter: ->
    @_elementForEmitter ||= document.createElement('emitter')
  

  emit: (type, detail) ->
    @GetElementForEmitter().dispatchEvent(new CustomEvent(type, { detail: detail }))
  

  on: (type, callback) ->
    @GetElementForEmitter().addEventListener(type, callback)


  off: (type, callback) ->
    @GetElementForEmitter().removeEventListener(type, callback)
  
  
  #
  #
  emitChange: ->
    @emit('change')


# Handler
#
Store.dispatchToken = Dispatcher.register (payload) ->
  action = payload.action
  
  switch action.type
    
    when Constants.Chart.DONE_FETCH_CHART
      data = data.push(Immutable.fromJS(action.json))
      Store.emitChange()


# Exports
#
module.exports = Store
