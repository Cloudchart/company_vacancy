# @cjsx React.DOM

# Imports
#
GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')

InsightOrigin = require('components/insight/origin')
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
    pin: React.PropTypes.oneOfType([React.PropTypes.string, React.PropTypes.object])
    renderedInsideModal: React.PropTypes.bool

  statics:
    queries:
      pin: ->
        """
          Pin {
            #{InsightOrigin.getQuery('pin')},
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
      pin: PinStore.cursor.items

  # getInitialState: ->


  # Lifecycle Methods
  #
  componentWillMount: ->
    @fetch()

  componentDidMount: ->
    if @props.renderedInsideModal
      setTimeout =>
        history.pushState({}, '', @getPin().url)
      , 250


  # Helpers
  #
  getPin: ->
    if typeof(@props.pin) is 'string'
      PinStore.cursor.items.cursor(@props.pin).deref(Immutable.Map({})).toJS()
    else if typeof(@props.pin) is 'object'
      @props.pin

  getInsight: ->
    pin = @getPin()
    if pin.parent_id then PinStore.get(pin.parent_id).toJS() else pin

  fetch: ->
    id = if typeof(@props.pin) is 'string'
      @props.pin
    else if typeof(@props.pin) is 'object'
      @props.pin.uuid

    GlobalState.fetch(@getQuery('pin'), id: id)

  isInsightEmpty: (pin) ->
    Object.keys(pin).length is 0

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
    pin = @getPin()

    if @isInsightEmpty(pin)
      <article className="insight-card placeholder"/>
    else
      insight = @getInsight()

      articte_classes = cx
        'insight-card': true
        modal: @props.renderedInsideModal

      attributes = @gatherPinAttributes(pin, insight)

      <div className="insight-card wrapper">
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
              <EditPinButton uuid = { insight.uuid } />
              <PinButton {...attributes} />
            </ul>
          </section>

        </article>

        <footer>
          <ShareButtons object = { pin } />
        </footer>
      </div>
