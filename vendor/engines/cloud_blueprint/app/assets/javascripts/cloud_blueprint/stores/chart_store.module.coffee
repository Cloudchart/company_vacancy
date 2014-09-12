# Imports
#
Dispatcher = require('dispatcher/dispatcher')


# Main
#

Store =


  noop: ->


# Handler
#
Store.dispatchToken = Dispatcher.register (payload) ->
  action = payload.action
  
  switch action.type
    
    when 'chart:fetch:done'
      console.log 'chart loaded'


# Exports
#
module.exports = Store
