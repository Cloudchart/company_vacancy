# @cjsx React.DOM

# Imports
# 
GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')

InsightContent = require('components/pinnable/insight_content')
Human = require('components/human')
EditPinButton = require('components/pinnable/edit_pin_button')
PinButton = require('components/pinnable/pin_button')


# Utils
#
cx = React.addons.classSet


# Main component
# 
module.exports = React.createClass

  displayName: 'InsightCard'
  
  mixins: [GlobalState.query.mixin]
  # propTypes: {}

  statics:
    queries:
      insight: ->
        """
          Pin {
            user,
            post {
              company
            }
          }
        """


  # Component Specifications
  # 
  # getDefaultProps: ->
  # getInitialState: ->

  
  # Lifecycle Methods
  # 
  componentWillMount: ->
    @fetch()

  componentDidMount: ->
    new ZeroClipboard(@refs.clip.getDOMNode())

  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->


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

  isInsightEmpty: ->
    Object.keys(@getInsight()).length is 0

  gatherPinAttributes: (insight) ->
    uuid: insight.uuid
    parent_id: insight.parent_id
    pinnable_id: insight.pinnable_id
    pinnable_type: insight.pinnable_type
    title: insight.content


  # Handlers
  # 
  handleCopyLinkClick: (event) ->
    console.log 'handleCopyLinkClick'


  # Renderers
  # 
  renderInsight: ->
    return null if @isInsightEmpty()
    insight = @getInsight()

    <article className="insight">
      <InsightContent
        pinnable_id = { insight.pinnable_id }
        pin_id = { insight.uuid }
      />

      <footer>
        <Human
          showUnicornIcon = { true }
          showLink = { true }
          type = "user"
          uuid = { insight.user_id }
        />

        <ul className="round-buttons">
          <EditPinButton uuid={ insight.uuid } />
          <PinButton {...@gatherPinAttributes(insight)} />
        </ul>

      </footer>
    </article>

  renderShareButtons: ->
    <section className="share-buttons">
      <ul>
        <li>Share!</li>
        <li ref="clip" onClick={ @handleCopyLinkClick } data-clipboard-text = 'Test me!' >Copy link</li>
        <li>Facebook</li>
        <li>Twitter</li>
        <li>LinkedIn</li>
      </ul>
    </section>


  # Main render
  # 
  render: ->
    card_classes = cx
      pin: true
      'cloud-card': true
      placeholder: @isInsightEmpty()

    <section className="pins cloud-columns">
      <section className="cloud-column">

        <section className={ card_classes }>
          { @renderInsight() }
        </section>

        { @renderShareButtons() }
      </section>
    </section>
