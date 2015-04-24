# @cjsx React.DOM
#
ModalStack   = require('components/modal_stack')
ModalHeader  = require('components/shared/modal_header')


module.exports = React.createClass
  
  displayName: "ModelError"

  propTypes:
    onClick: React.PropTypes.func
    message: React.PropTypes.string

  getDefaultProps: ->
    onClick: ModalStack.hide
    message: "Your database returned 0 or did not return at all. Please update and/or reboot your device and press any key to cancel."


  render: ->
    <article className="error">
      <ModalHeader text = "Something went wrong" />
      <section className="content">
        <p>{ @props.message }</p>
        <figure />
        <button className="cc" onClick = { @props.onClick }>
          Sure thing
        </button>
      </section>
    </article>
