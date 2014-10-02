# Imports
#
Dispatcher = require('dispatcher/dispatcher')


# Exports
#
module.exports =
  

  show: (component) ->
    Dispatcher.handleClientAction
      type: 'modal:show'
      data: [component]
    
    
  hide: ->
    Dispatcher.handleClientAction
      type: 'modal:hide'
      data: []

    
  close: ->
    Dispatcher.handleClientAction
      type: 'modal:close'
      data: []
