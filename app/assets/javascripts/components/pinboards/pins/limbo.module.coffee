# @cjsx React.DOM

GlobalState      = require('global_state/state')

PinStore         = require('stores/pin_store')

PinsList         = require('components/pinboards/pins')
PinComponent     = require('components/pinboards/pin')


# Utils
#
cx = React.addons.classSet


# Main component
# 
MainComponent = React.createClass

  displayName: 'LimboInsights'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      insights: ->
        """
          Viewer {
            limbo_pins {
              #{PinComponent.getQuery('pin')}
            }
          }
        """

  getDefaultProps: ->
    cursor: 
      pins: PinStore.cursor.items

  getInitialState: ->
    isLoaded: false


  # Helpers
  # 
  isLoaded: ->
    @state.isLoaded

  fetch: ->
    GlobalState.fetch(@getQuery('insights'))

  gatherInsights: ->
    @props.cursor.pins
      .filter (pin) =>
        !pin.get('parent_id') && !pin.get('pinnable_id') && 
        pin.get('author_id') && pin.get('content')
      .valueSeq()
      .sortBy (pin) -> pin.get('created_at')
      .reverse()
      .toArray()


  # Lifecycle Methods
  # 
  componentWillMount: ->
    @fetch().then => @setState isLoaded: true


  # Main render
  # 
  render: ->
    return null unless @isLoaded()

    <PinsList pins = { @gatherInsights() } showPinButton = { false } />


# Exports
# 
module.exports = MainComponent
