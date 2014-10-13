# Imports
#
Dispatcher = require('dispatcher/dispatcher')


# Main
#
Module = (definition = {}) ->
  
  Actions =
    
    createClientServerActions: (type, args...) ->
      initial = _.initial(args)
      last    = _.last(args)
      
      clientAction: ->
        Dispatcher.handleClientAction
          type: type
          data: args
      
      serverDoneAction: (json) ->
        Dispatcher.handleServerAction
          type: "#{type}:done"
          data: [initial..., json, last]
      
      serverFailAction: (xhr) ->
          type: "#{type}:fail"
          data: [initial..., xhr.responseJSON, xhr, last]
  
  
  _.extend Actions, definition
  
  

# Exports
#
module.exports = Module
