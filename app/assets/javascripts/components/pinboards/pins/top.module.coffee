# @cjsx React.DOM


GlobalState     = require('global_state/state')


# Stores
#
PinStore        = require('stores/pin_store')
UserStore       = require('stores/user_store.cursor')


# Components
#
PinsList         = require('components/pinboards/pins')
PinComponent     = require('components/pinboards/pin')


# Exports
#
module.exports = React.createClass

  displayName: 'TopInsights'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      insights: ->
        """
          Viewer {
            top_insights {
              #{PinComponent.getQuery('pin')}
            }
          }
        """

  getInitialState: ->
    isLoaded: false


  # Helpers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('insights'))

  gatherInsights: ->
    @cursor.pins
      .filter (pin) =>
        pin.get('pinnable_id') && pin.get('content') && !pin.get('parent_id')
      .valueSeq()
      .sort (pinA, pinB) -> 
        if pinA.get('pins_count') == pinB.get('pins_count')
          pinA.get('created_at') - pinB.get('created_at')
        else
          pinA.get('pins_count') - pinB.get('pins_count')
      .reverse()
      .take(4)
      .toArray()


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      pins: PinStore.cursor.items

    @fetch().then => @setState isLoaded: true


  # Renderers
  #
  render: ->
    return null unless @state.isLoaded

    <section>
      <header>Trending Insights</header>
      <PinsList pins = { @gatherInsights() } />
    </section>
