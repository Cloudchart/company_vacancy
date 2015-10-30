# @cjsx React.DOM

# Imports
#

GlobalState = require('global_state/state')

PinStore    = require('stores/pin_store')

Insight               = require('components/cards/insight_card')
TabNav                = require('components/shared/tab_nav')
ConnectedCollections  = require('components/insight/collections')
Reflections           = require('components/insight/reflections')
Reactions             = require('components/insight/reactions')

# Exports
#
module.exports = React.createClass

  displayName: 'InsightApp'

  propTypes:
    pin: React.PropTypes.string.isRequired

  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  getDefaultProps: ->
    {}


  getInitialState: ->
    currentTab: 'collections'
    ready:      false


  statics:
    queries:
      pin: ->
        """
          Pin {
            #{Reactions.getQuery('pin')},
            #{Insight.getQuery('pin')},
            parent {
              #{Insight.getQuery('pin')},
              edges {
                connected_collections_ids,
                reflections_ids
              }
            },
            edges {
              connected_collections_ids,
              reflections_ids
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.pin }).then =>
      @setState
        ready:  true
        pin:    @cursor.pin.deref().toJS()


  # Helpers
  #

  effective_pin: ->
    PinStore.get(@state.pin.parent_id || @state.pin.id).toJS()


  gatherTabs: ->
    tabs = []

    collections_count = Immutable.Set(@effective_pin().connected_collections_ids).size
    if collections_count > 0
      tabs.push
        id:       'collections'
        title:    'Collections'
        counter:  '' + collections_count

    reflections_count = @effective_pin().reflections_ids.length

    if reflections_count > 0
      tabs.push
        id:       'reflections'
        title:    'Reflections'
        counter:  '' + reflections_count

    tabs


  # Handlers
  #

  handleTabChange: (id) ->
    @setState
      currentTab: id


  # Lifecycle
  #

  onGlobalStateChange: ->
    @setState
      pin: @cursor.pin.deref().toJS()


  componentWillMount: ->
    @cursor =
      pin: PinStore.cursor.items.cursor(@props.pin)

    if tab = window.location.hash.split('#')[1]
      @setState
        currentTab: tab


  componentDidMount: ->
    @fetch()


  componentDidUpdate: ->
    tabs = @gatherTabs()
    if tabs.length > 0
      unless Immutable.List(tabs).find((tab) => tab.id == @state.currentTab)
        @setState
          currentTab: tabs[0].id


  # Render
  #

  renderTabs: ->
    <TabNav tabs={ @gatherTabs() } onChange={ @handleTabChange } currentTab={ @state.currentTab } />


  renderConnections: ->
    return null if @gatherTabs().length == 0

    content = switch @state.currentTab
      when 'collections'
        <ConnectedCollections pin={ @effective_pin().id } />
      when 'reflections'
        <Reflections insight={ @effective_pin().id } />
      else
        null

    <div className="connections">
      { content }
    </div>


  render: ->
    return null unless @state.ready

    <div className="cc-container-common glued">
      <article className="insight-app standalone">
        <Insight
          pin   = { @effective_pin().id }
          scope = "standalone"
        />

        { @renderTabs() }

        { @renderConnections() }

        <Reactions pin={ @effective_pin().id } />
      </article>
    </div>
