# @cjsx React.DOM

GlobalState           = require('global_state/state')
ModalStack            = require('components/modal_stack')
ReflectOnInsightForm  = require('components/form/insight/reflect_on_insight')

# Exports
#
module.exports = React.createClass

  displayName: 'InsightReflection'

  propTypes:
    insight: React.PropTypes.string.isRequired


  handleClick: (status, event) ->
    event.preventDefault()
    @showForm(status)

  showForm: (status) ->
    ModalStack.show(<ReflectOnInsightForm status={ status } insight={ @props.insight } onDone={ @hideFormOnDone } onCancel={ @hideFormOnCancel } />)

  hideFormOnDone: ->
    GlobalState.fetchEdges('Pin', @props.insight)
    ModalStack.hide()

  hideFormOnCancel: ->
    ModalStack.hide()

  render: ->
    <header className="reflection">
      <span>Did it work?</span>
      <a href="#" onClick={ @handleClick.bind(@, true) }>Yes</a>
      <a href="#" onClick={ @handleClick.bind(@, false) }>No</a>
    </header>
