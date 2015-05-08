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
    showPlaceholders: React.PropTypes.bool

  getDefaultProps: ->
    showOnlyInsights: false
    showPlaceholders: false

  getInitialState: ->
    isLoaded: false


  # Helpers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pins'), id: @props.user_id)

  isLoaded: ->
    @cursor.pins.deref(false) || @state.isLoaded

  gatherPins: ->
    @cursor.pins
      .filter (pin) =>
        pin.get('user_id') == @props.user_id && pin.get('pinnable_id') &&
        (!@props.showOnlyInsights || pin.get('content') || pin.get('parent_id'))
      .valueSeq()
      .sortBy (pin) -> pin.get('created_at')
      .reverse()
      .toArray()


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      pins: PinStore.cursor.items

    @fetch().then => @setState isLoaded: true unless @isLoaded()


  # Renderers
  #
  render: ->
    if @isLoaded()
      if (pins = @gatherPins()).length > 0
        <PinsList pins = { @gatherPins() } />
      else
        <p>Collect successful founders' insights and put them to action.</p>
    else if @props.showPlaceholders
      <section className="pins cloud-columns cloud-columns-flex">
        <section className="cloud-column">
          <section className="pin cloud-card placeholder" />
        </section>
        <section className="cloud-column">
          <section className="pin cloud-card placeholder" />
        </section>
      </section>
    else
      null
