# Imports
#
Dispatcher    = require('dispatcher/dispatcher')
EventEmitter  = require('utils/event_emitter')
Constants     = require('constants')
uuid          = require('utils/uuid')


# Variables
#


data = new Immutable.Map


# Main
#
Store =
  
  # Create
  #
  create: ->
    key   = uuid()
    model = new Immutable.Map
    data  = data.set(key, model)
    key
  
  
  # Get
  #
  get: (key) ->
    data.get(key).toJS()
  
  
  # Update
  #
  update: (key, attributes = {}) ->
    console.log key
    model = data.get(key).merge(attributes)
    data  = data.set(key, model)
  

# Event Emitter
#
_.extend Store, EventEmitter


# Dispatching
#
Store.dispatchToken = Dispatcher.register (payload) ->
  action = payload.action      

  switch action.type

    when Constants.Token.CREATE
      Store.update(action.key, action.attributes)
      Store.emitChange()


# Exports
#
module.exports = Store
