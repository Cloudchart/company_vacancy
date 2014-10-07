# Imports
#
Dispatcher = require('dispatcher/dispatcher')


# Exports
#
module.exports =
  

  show: (component, options = {}) ->
    Dispatcher.handleClientAction
      type: 'modal:show'
      data: [component, options]
    
    
  hide: ->
    Dispatcher.handleClientAction
      type: 'modal:hide'
      data: []

    
  close: ->
    Dispatcher.handleClientAction
      type: 'modal:close'
      data: []
