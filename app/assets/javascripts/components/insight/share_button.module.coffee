# @cjsx React.DOM

# Imports
# 
ModalStack = require('components/modal_stack')
InsightCard = require('components/cards/insight_card')


# Utils
#
# cx = React.addons.classSet


# Main component
# 
module.exports = React.createClass

  displayName: 'InsightShareButton'
  # mixins: []
  # statics: {}
  propTypes:
    insight: React.PropTypes.object.isRequired


  # Component Specifications
  # 
  # getDefaultProps: ->
  # getInitialState: ->

  
  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->


  # Helpers
  # 
  shouldRenderShareButton: ->
    @props.insight.parent_id is null and @props.insight.pinnable_id and
    @props.insight.content and @props.insight.is_approved


  # Handlers
  # 
  handleShareButtonClick: (event) ->
    history.pushState({}, '', @props.insight.insight_url)
    ModalStack.show(<InsightCard insight = { @props.insight.uuid } renderedInsideModal = true />, shouldGetHistoryBack: true)


  # Renderers
  # 
  # renderSomething: ->


  # Main render
  # 
  render: ->
    return null unless @shouldRenderShareButton()

    <li className="round-button with-content share" onClick={@handleShareButtonClick}>
      <i className="fa fa-share"></i>
      <span>Share</span>
    </li>
