# Imports
#
Dispatcher = require('dispatcher/dispatcher')


# Main
#
Module =
  
  toggle: (from) ->
    Dispatcher.handleClientAction
      type: 'identity_box:toggle'
      from: from


# Exports
#
module.exports = Module
