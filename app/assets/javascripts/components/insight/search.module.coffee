# @cjsx React.DOM

GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')

InsightCard = require('components/cards/insight_card')
ListOfCards = require('components/cards/list_of_cards')

# cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'InsightsSearch'
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  # propTypes:
    # some_object: React.PropTypes.object.isRequired

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
        search_pins_ids: json.query.search_pins.ids
        ready: true

  # Component Specifications
  #
  # getDefaultProps: ->

  getInitialState: ->
    query: ''


  # Lifecycle Methods
  #
  # componentWillMount: ->

  componentDidMount: ->
    @fetch()

  # componentWillUnmount: ->


  # Helpers
  #
  # getSomething: ->


  # Handlers
  #
  handleSearchChange: (event) ->
    @setState query: event.target.value

  handleSearchKeyDown: (event) ->
    if event.key == 'Enter'
      @setState ready: false
      @fetch()


  # Renderers
  #
  renderLoader: ->
    return null if @state.ready
    <i className="fa fa-spin fa-spinner"></i>

  renderSearchInput: ->
    <input 
      className = "cc-input"
      value = { @state.query }
      placeholder = "Search insights"
      onChange = { @handleSearchChange } 
      onKeyDown = { @handleSearchKeyDown }
    />

  renderSearchItems: ->
    return null unless @state.ready
    @state.search_pins_ids.map (id) -> <InsightCard key={ id } pin={ id } scope = 'pinboard' />


  # Main render
  #
  render: ->
    <section className="cc-container-common">
      <section className="search">
        { @renderSearchInput() }
        { @renderLoader() }
      </section>

      <ListOfCards>
        { @renderSearchItems() }
      </ListOfCards>
    </section>
