# @cjsx React.DOM

ModalStack   = require('components/modal_stack')
ModalError   = require('components/error/modal')


# Exports
#
module.exports = React.createClass

  displayName: 'ErrorTrigger'

  # Lifecycle methods
  #
  componentDidMount: ->
    ModalStack.show ModalError(@props)


  # Renderers
  #
  render: ->
    null