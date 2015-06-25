# @cjsx React.DOM

# Imports
#
GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')

InsightContent = require('components/pinnable/insight_content')
Human = require('components/human')
EditPinButton = require('components/pinnable/edit_pin_button')
PinButton = require('components/pinnable/pin_button')
CloseModalButton = require('components/form/buttons').CloseModalButton
ShareButtons = require('components/shared/share_buttons')


# Utils
#
cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'InsightCard'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    renderedInsideModal: React.PropTypes.bool

  statics:
    queries:
      insight: ->
        """
          Pin {
            user,
            parent {
              edges {
                url,
                facebook_share_url,
                twitter_share_url
              }
            },
            post {
              company
            },
            edges {
              url,
              facebook_share_url,
              twitter_share_url,
              context
            }
          }
        """


  # Component Specifications
  #
  getDefaultProps: ->
    renderedInsideModal: false
    cursor:
      insight: PinStore.cursor.items

  # getInitialState: ->


  # Lifecycle Methods
  #
  componentWillMount: ->
    @fetch()


  # Helpers
  #
  getInsight: ->
    if typeof(@props.insight) is 'string'
      PinStore.cursor.items.cursor(@props.insight).deref(Immutable.Map({})).toJS()
    else if typeof(@props.insight) is 'object'
      @props.insight

  fetch: ->
    id = if typeof(@props.insight) is 'string'
      @props.insight
    else if typeof(@props.insight) is 'object'
      @props.insight.uuid

    GlobalState.fetch(@getQuery('insight'), id: id)

  isInsightEmpty: (insight) ->
    Object.keys(insight).length is 0

  gatherPinAttributes: (pin, insight) ->
    uuid:           insight.uuid
    parent_id:      insight.parent_id
    pinnable_id:    pin.pinnable_id
    pinnable_type:  pin.pinnable_type
    title:          insight.content


  # Handlers
  #
  # handleThingClick: (event) ->


  # Renderers
  #
  # renderSomething: ->


  # Main render
  #
  render: ->
    pin = @getInsight()

    if @isInsightEmpty(pin)
      <article className="insight-card placeholder"/>
    else
      insight = if pin.parent_id then PinStore.get(pin.parent_id).toJS() else pin

      articte_classes = cx
        'insight-card': true
        modal: @props.renderedInsideModal

      attributes = @gatherPinAttributes(pin, insight)

      <article className={articte_classes}>
        { <CloseModalButton shouldDisplay = { @props.renderedInsideModal } /> }

        <section className="content">
          <InsightContent
            pinnable_id = { pin.pinnable_id }
            pin_id = { insight.uuid }
          />

          <Human
            showUnicornIcon = { true }
            showLink = { true }
            type = "user"
            uuid = { insight.user_id }
          />

          <ul className="round-buttons">
            <EditPinButton uuid={ insight.uuid } />
            <PinButton {...attributes} />
          </ul>
        </section>

        <footer>
          <ShareButtons object = { insight } renderedInsideModal = { @props.renderedInsideModal } />
        </footer>
      </article>
