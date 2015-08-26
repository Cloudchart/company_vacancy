# @cjsx React.DOM

GlobalState = require('global_state/state')

InsightCard = require('components/cards/insight_card')
ListOfCards = require('components/cards/list_of_cards')
SeeMore = require('components/insight/see_more')

NotificationsPushApi = require('push_api/notifications_push_api')

# cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'InsightsSearch'
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    query: React.PropTypes.string

  statics:
    queries:
      viewer: ->
        """
          Viewer {
            search_pins {
              #{InsightCard.getQuery('pin')}
            }
          }
        """


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('viewer'), { force: true, params: { query: @state.query } }).then (json) =>
      @setState
        search_pins_ids: if json.query.search_pins then json.query.search_pins.ids else []
        ready: true
        sync: false

      @changeHistory()
      NotificationsPushApi.post_to_slack('searched_insights', query: @state.query)

  # Component Specifications
  #
  # getDefaultProps: ->

  getInitialState: ->
    query: @props.query || ''
    ready: false
    sync: false


  # Lifecycle Methods
  #
  # componentWillMount: ->

  componentDidMount: ->
    @search() if @state.query

  # componentWillUnmount: ->


  # Helpers
  #
  search: ->
    if @state.query.length <= 1
      @setState
        ready: false
        sync: false
        search_pins_ids: []
      @changeHistory()
    else
      @setState
        ready: false
        sync: true
      @fetch()

  getInsightCards: ->
    search_pins_ids = @state.search_pins_ids

    if SeeMore.shouldDisplayComponent(@state.search_pins_ids.length)
      search_pins_ids = search_pins_ids.slice(0, SeeMore.takeSize())

    search_pins_ids.map (id) -> <InsightCard key={ id } pin={ id } scope = 'pinboard' />

  changeHistory: ->
    keyword = if @state.query.length <= 1 then '' else "?keyword=#{@state.query}"
    history.pushState({}, '', location.href.split('?')[0] + keyword)


  # Handlers
  #
  handleInputChange: (event) ->
    @setState query: event.target.value

  handleInputKeyDown: (event) ->
    @search() if event.key == 'Enter'

  handleButtonClick: (event) ->
    @search()


  # Renderers
  #
  renderSeeMore: ->
    return null unless @state.ready
    <SeeMore pinsSize = { @state.search_pins_ids.length } type = "search result" />

  renderButton: ->
    loader = if @state.sync then <i className="fa fa-spin fa-spinner"/> else null

    <button className="cc" onClick={ @handleButtonClick } >
      <span>Search</span>
      { loader }
    </button>

  renderInput: ->
    <input 
      className = "cc-input"
      value = { @state.query }
      placeholder = "Find insights"
      autoFocus = true
      onChange = { @handleInputChange }
      onKeyDown = { @handleInputKeyDown }
    />

  renderPins: ->
    <ListOfCards>
      { @getInsightCards() }
    </ListOfCards>

  renderResult: ->
    if @state.sync
      null
    else if @state.ready && @state.search_pins_ids.length > 0
      @renderPins()
    else if @state.ready
      <p>
        { "We found nothing on this" }
      </p>
    else
      <p>
        { "We’ll search through insights, insight authors, their twitter @handles, and insight sources" }
      </p>


  # Main render
  #
  render: ->
    <section className="cc-container-common pins-search">
      <section className="search-input">
        { @renderInput() }
        { @renderButton() }
      </section>

      <section className="cc-container-common result">
        { @renderResult() }
        { @renderSeeMore() }
      </section>
    </section>
