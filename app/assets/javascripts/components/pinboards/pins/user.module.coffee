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

  displayName: 'UserPins'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      pins: ->
        """
          User {
            pins {
              #{PinComponent.getQuery('pin')}
            }
          }
        """

    isEmpty: (user_id, options={}) ->
      !PinStore
        .filterPinsForUser(user_id, onlyInsights: options.onlyInsights)
        .size

  propTypes:
    user_id:          React.PropTypes.string.isRequired
    showOnlyInsights: React.PropTypes.bool

  getDefaultProps: ->
    showOnlyInsights: false

  getInitialState: ->
    isLoaded: false


  # Helpers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pins'), id: @props.user_id)

  isLoaded: ->
    @state.isLoaded

  gatherPins: ->
    PinStore.filterPinsForUser(@props.user_id, onlyInsights: @props.showOnlyInsights)
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
