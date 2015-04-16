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

    isEmpty: (user_id) ->
      !PinStore.cursor.items
        .filter (pin) =>
          pin.get('user_id') == user_id && pin.get('pinnable_id') &&
          (pin.get('content') || pin.get('parent_id'))
        .size

  propTypes:
    user_id:          React.PropTypes.string.isRequired
    showOnlyInsights: React.PropTypes.bool

  getDefaultProps: ->
    showOnlyInsights: false


  # Helpers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pins'), id: @props.user_id)

  isLoaded: ->
    @cursor.pins.deref(false)

  gatherPins: ->
    @cursor.pins
      .filter (pin) =>
        pin.get('user_id') == @props.user_id && pin.get('pinnable_id') &&
        (!@props.showOnlyInsights || pin.get('content') || pin.get('parent_id'))
      .valueSeq()
      .sortBy (pin) -> pin.get('created_at')
      .reverse()


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      pins: PinStore.cursor.items

    @fetch() unless @isLoaded()


  # Renderers
  #
  renderPins: ->
    @gatherPins().toArray()


  render: ->
    return null unless @isLoaded()

    <PinsList pins = { @gatherPins() } />
