# @cjsx React.DOM
#

ModalStack      = require('components/modal_stack')
StandardButton  = require('components/form/buttons').StandardButton

module.exports = React.createClass
  
  displayName: "ModalHeader"


  # Component Specifications
  # 
  propTypes:
    text:    React.PropTypes.string
    onClose: React.PropTypes.func

  geDefaultProps: ->
    text:    ""
    onClose: -> ModalStack.hide()

  render: ->
    <header className="modal-header">
      <h1>{ @props.text }</h1>
      <StandardButton 
        className  = "close-button transparent"
        onClick    = { @props.onClose }
        iconClass  = "cc-icon cc-times" />
    </header>
