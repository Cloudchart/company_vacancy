# @cjsx React.DOM


ModalStack        = require('components/modal_stack')
SendInsightForm   = require('components/form/insight/send_insight')


# Utils
#
cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'InsightSaveButton'

  # Specification
  #

  getDefaultProps: ->
    sync:   false


  # Show Form
  #
  showForm: ->
    ModalStack.show(<SendInsightForm pin={ @props.pin } onCancel={ @hideForm } onDone={ @hideForm } />)


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

    className = cx
      'save':     true

    iconClassName = cx
      'fa':         true
      'fa-share':   true
      'fa-spin':    @props.sync   == true

    <li className={ className }>
      <i className={ iconClassName } onClick={ @handleClick } />
    </li>
