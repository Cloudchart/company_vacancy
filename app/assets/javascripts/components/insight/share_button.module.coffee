# @cjsx React.DOM

# Imports
#
GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')

ModalStack = require('components/modal_stack')
InsightApp = require('components/insight_app')


# Main component
#
module.exports = React.createClass

  displayName: 'InsightShareButton'

  propTypes:
    pin: React.PropTypes.object.isRequired

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      pin: ->
        """
          Pin {
            parent
          }
        """


  # Component Specifications
  #
  getDefaultProps: ->
    shouldFetch: true


  # Lifecycle Methods
  #
  componentWillMount: ->
    @fetch() if @props.shouldFetch


  # Helpers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pin'), id: @props.pin.uuid)

  shouldRenderShareButton: ->
    insight = if @props.pin.parent_id then PinStore.get(@props.pin.parent_id).toJS() else @props.pin
    insight.is_approved


  # Handlers
  #
  handleShareButtonClick: (event) ->
    event.stopPropagation()
    event.preventDefault()

    ModalStack.show(<InsightApp pin = { @props.pin.uuid } renderedInsideModal = true />, shouldGetHistoryBack: true)


  # Main render
  #
  render: ->
    return null unless @shouldRenderShareButton()

    <li className="round-button with-content share" onClick={ @handleShareButtonClick }>
      <i className="fa fa-share"></i>
      <span>Share</span>
    </li>
