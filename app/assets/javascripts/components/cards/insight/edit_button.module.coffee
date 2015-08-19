# @cjsx React.DOM


ModalStack    = require('components/modal_stack')
PinForm       = require('components/form/pin_form')


# Utils
#
cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'InsightEditButton'

  # Specification
  #

  propTypes:
    pin:          React.PropTypes.string.isRequired
    is_editable:  React.PropTypes.bool


  # Show Form
  #
  showForm: ->
    ModalStack.show(<PinForm uuid={ @props.pin } onDone={ @hideForm } onCancel={ @hideForm } />)


  # Hide Form
  #
  hideForm: ->
    ModalStack.hide()
    @props.onDone() if typeof @props.onDone is 'function'


  # Handle Click
  #
  handleClick: ->
    @showForm()


  # Main Render
  #
  render: ->
    return null unless @props.is_editable

    className = cx
      'edit':     true

    iconClassName = cx
      'fa':         true
      'fa-pencil':  true

    <li className={ className }>
      <i className={ iconClassName } onClick={ @handleClick } />
    </li>
