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
            parent,
            post {
              company
            },
            edges {
              insight_url,
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

  getInitialState: ->
    display_mode: null


  # Lifecycle Methods
  #
  componentWillMount: ->
    @fetch()

  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->

  componentDidUpdate: (prevProps, prevState) ->
    if @refs.clip
      new ZeroClipboard(@refs.clip.getDOMNode())

    if @refs.copy_link_input
      copy_link_input = @refs.copy_link_input.getDOMNode()
      copy_link_input.setSelectionRange(0, copy_link_input.value.length)

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

  isInsightEmpty: (insight) ->
    Object.keys(insight).length is 0

  gatherPinAttributes: (insight) ->
    uuid: insight.uuid
    parent_id: insight.parent_id
    pinnable_id: insight.pinnable_id
    pinnable_type: insight.pinnable_type
    title: insight.content

  openShareWindow: (url) ->
    window.open(url, '_blank', 'location=yes,width=640,height=480,scrollbars=yes,status=yes')


  # Handlers
  #
  handleCopyLinkButtonClick: (event) ->
    @setState display_mode: 'copy_link'

  handleCopyLinkClick: (event) ->
    @setState display_mode: null

  handleFacebookLinkClick: (insight, event) ->
    @openShareWindow(insight.facebook_share_url)

  handleTwitterLinkClick: (insight, event) ->
    @openShareWindow(insight.twitter_share_url)


  # Renderers
  #
  renderShareButtons: (insight) ->
    <ul className="share-buttons">
      <li>Share!</li>

      <li>
        <button className="cc" onClick={ @handleCopyLinkButtonClick }>Copy link</button>
      </li>

      <li>
        <button className="cc" onClick={@handleFacebookLinkClick.bind(@, insight)}>
          <i className="fa fa-facebook"></i>
        </button>
      </li>

      <li>
        <button className="cc" onClick={@handleTwitterLinkClick.bind(@, insight)}>
          <i className="fa fa-twitter"></i>
        </button>
      </li>
    </ul>

  renderCopyLinkSection: (insight) ->
    <ul className="copy-link">
      <li>Copy link</li>

      <li>
        <input id="copy_link_input" ref="copy_link_input" className="cc-input" value={insight.insight_url} readOnly={true} />
      </li>

      <li>
        <button ref="clip" data-clipboard-target="copy_link_input" className="cc" onClick={@handleCopyLinkClick} title="Copy link to clipboard">
          <i className="fa fa-check"></i>
        </button>
      </li>
    </ul>


  # Main render
  #
  render: ->
    insight = @getInsight()

    if @isInsightEmpty(insight)
      <article className="insight-card placeholder"/>
    else
      articte_classes = cx
        'insight-card': true
        modal: @props.renderedInsideModal

      <article className={articte_classes}>
        { <CloseModalButton shouldDisplay = { @props.renderedInsideModal } /> }

        <section className="content">
          <InsightContent
            pinnable_id = { insight.pinnable_id }
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
            <PinButton {...@gatherPinAttributes(insight)} />
          </ul>
        </section>

        <footer>
          {
            if @state.display_mode is 'copy_link'
              @renderCopyLinkSection(insight)
            else
              @renderShareButtons(insight)
          }
        </footer>
      </article>
