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

  displayName: 'PinboardPins'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      pins: ->
        """
          Pinboard {
            pins {
              #{PinComponent.getQuery('pin')}
            }
          }
        """

  propTypes:
    pinboard_id:     React.PropTypes.string.isRequired

  getInitialState: ->
    isLoaded: false


  # Helpers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pins'), id: @props.pinboard_id)

  isLoaded: ->
    @state.isLoaded

  gatherPins: ->
    PinStore.filterByPinboardId(@props.pinboard_id)
      .valueSeq()
      .sortBy (pin) -> pin.get('created_at')
      .reverse()
      .toArray()


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      pins: PinStore.cursor.items

    @fetch().then(=> @setState isLoaded: true) unless @isLoaded()


  # Renderers
  #
  render: ->
    return null unless @isLoaded()
    
    <PinsList pins = { @gatherPins() } />
