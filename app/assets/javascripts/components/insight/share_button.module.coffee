# @cjsx React.DOM

# Imports
#
ModalStack = require('components/modal_stack')
InsightCard = require('components/cards/insight_card')


# Main component
#
module.exports = React.createClass

  displayName: 'InsightShareButton'

  propTypes:
    insight: React.PropTypes.object.isRequired


  # Helpers
  #
  shouldRenderShareButton: ->
    @props.insight.is_suggestion ||
    (
      @props.insight.parent_id is null and @props.insight.pinnable_id and
      @props.insight.content and @props.insight.is_approved
    )


  # Handlers
  #
  handleShareButtonClick: (event) ->
    history.pushState({}, '', @props.insight.insight_url)
    ModalStack.show(<InsightCard insight = { @props.insight.uuid } renderedInsideModal = true />, shouldGetHistoryBack: true)


  # Main render
  #
  render: ->
    return null unless @shouldRenderShareButton()

    <li className="round-button with-content share" onClick={@handleShareButtonClick}>
      <i className="fa fa-share"></i>
      <span>Share</span>
    </li>
