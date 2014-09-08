##= require dispatcher/dispatcher.module


Dispatcher = require('dispatcher/dispatcher')


# Actions
#
Actions =

  # Close Button Click
  #
  close: ->
    cc.blueprint.react.modal.hide()


# Exports
#
module.exports = Actions
