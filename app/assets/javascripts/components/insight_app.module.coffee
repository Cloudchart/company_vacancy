# @cjsx React.DOM

# Imports
#

GlobalState = require('global_state/state')

PinStore    = require('stores/pin_store')

Insight               = require('components/cards/insight_card')
TabNav                = require('components/shared/tab_nav')
ConnectedCollections  = require('components/insight/collections')
Reflections           = require('components/insight/reflections')

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
    currentTab: 'reflections'
    ready:      false


  statics:
    queries:
      pin: ->
        """
          Pin {
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

    tabs.push
      id:       'collections'
      title:    'Collections'
      counter:  '' + Immutable.Set(@effective_pin().connected_collections_ids).size

    tabs.push
      id:       'reflections'
      title:    'Reflections'
      counter:  '' + @effective_pin().reflections_ids.length

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


  componentDidMount: ->
    @fetch()


  # Render
  #

  renderTabs: ->
    <TabNav tabs={ @gatherTabs() } onChange={ @handleTabChange } currentTab={ @state.currentTab } />


  renderConnections: ->
    switch @state.currentTab
      when 'collections'
        <ConnectedCollections pin={ @effective_pin().id } />
      when 'reflections'
        <Reflections insight={ @effective_pin().id } />
      else
        null

  render: ->
    return null unless @state.ready

    <div className="cc-container-common glued">
      <article className="insight-app standalone">
        <Insight
          pin   = { @effective_pin().id }
          scope = "standalone"
        />

        { @renderTabs() }

        <div className="connections">
          { @renderConnections() }
        </div>
      </article>
    </div>
