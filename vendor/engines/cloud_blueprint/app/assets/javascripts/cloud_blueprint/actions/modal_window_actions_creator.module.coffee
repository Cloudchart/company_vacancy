##= require dispatcher/dispatcher.module


Dispatcher = require('dispatcher/dispatcher')


# Actions
#
Actions =
  
  
  # Show
  #
  show: (component, options = {}) ->
    Dispatcher.handleClientAction
      type:       'blueprint:chart:modal:show'
      component:  component
      options:    options
  

  # Close Button Click
  #
  close: ->
    cc.blueprint.react.modal.hide()


# Exports
#
module.exports = Actions
