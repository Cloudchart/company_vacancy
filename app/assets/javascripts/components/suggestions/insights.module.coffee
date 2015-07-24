# @cjsx React.DOM

GlobalState   = require('global_state/state')

Insight       = require('components/cards/pin_card')

UserStore     = require('stores/user_store.cursor')
PinboardStore = require('stores/pinboard_store')
PinStore      = require('stores/pin_store')

# Exports
#
module.exports = React.createClass

  displayName: 'SiggestedInsights'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:
    queries:
      pinboard: ->
        """
          Pinboard {
            pins {
              #{Insight.getQuery('pin')},
              parent {
                #{Insight.getQuery('pin')}
              }
            },
            edges {
              pins
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.pinboard }).then =>
      @setState
        ready: true


  filterInsights: (ids) ->
    return ids if @state.query.trim() == ''

    queries = Immutable.Seq(@state.query.trim().toLowerCase().split(' '))

    ids
      .filter (id) ->
        pin     = PinStore.get(id) ; return false unless pin
        user    = UserStore.get(pin.get('user_id')) ; return false unless user
        entries = Immutable.Seq([pin.get('content', '').toLowerCase(), user.get('full_name', '').toLowerCase()])

        queries.every (query) ->
          entries.some (entry) ->
            entry.indexOf(query) > -1


  startPackery: ->
    @packery = new Packery @refs['section'].getDOMNode(),
      transitionDuration:   '0ms'
      itemSelector:         '.cloud-column'


  updatePackery: ->
    cancelAnimationFrame @packery_timeout
    @packery_timeout = requestAnimationFrame =>
      @packery.reloadItems()
      @packery.layout()

  stopPackery: ->
    @packery.off()


  # Events
  #
  handleQueryChange: (event) ->
    @setState
      query: event.target.value


  handleClick: (id, event) ->
    event.preventDefault()
    @props.onSelect(id) if typeof @props.onSelect is 'function'


  # Lifecycle
  #
  componentWillMount: ->
    @cursor =
      pinboard: PinboardStore.cursor.items.cursor(@props.pinboard)


  componentDidMount: ->
    @fetch()
    @startPackery()


  componentDidUpdate: ->
    @updatePackery()


  componentWillUnmount: ->
    @stopPackery()


  getInitialState: ->
    ready: false
    query: ''


  # Renders
  #
  renderFilter: ->
    <header className="filter">
      <input
        autoFocus   = true
        value       = { @state.query }
        onChange    = { @handleQueryChange }
        placeholder = "Search by content or author"
      />
    </header>

  renderPlaceholder: (_, i) ->
    <section key={ i } className="cloud-column">
      <section className="cloud-card placeholder pin" />
    </section>


  renderInsight: (id) ->
    <section key={ id } className="cloud-column">
      <Insight
        pin = { id }
        className = "hoverable"
        onClick = { @handleClick.bind(@, id) }
        onUpdate = { @updatePackery }
        shouldRenderHeader = false
        shouldRenderFooter = false
      />
    </section>


  renderInsights: ->
    if @state.ready

      ids = @cursor.pinboard
        .get('pins', Immutable.Seq())
        .map (pin) ->
          if pin.get('is_insight') then pin.get('id') else pin.get('parent_id')
        .filter (pin) ->
          !!pin
        .toSetSeq()

      @filterInsights(ids).map @renderInsight

    else
      Immutable.Repeat('placeholder', 2).map @renderPlaceholder


  # Main Render
  #
  render: ->
    <div className="wrapper">
      { @renderFilter() }
      <section ref="section" className="pins cloud-columns cloud-columns-flex">
        { @renderInsights().toArray() }
      </section>
    </div>
