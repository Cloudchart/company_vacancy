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
    message: "We've been notified about the issue. Try to repeat this action later."


  render: ->
    <article className="error">
      <ModalHeader text = "Something went wrong" />
      <section className="content">
        <p>{ @props.message }</p>
        <figure />
        <button className="cc" onClick = { @props.onClick }>
          Okay
        </button>
      </section>
    </article>
