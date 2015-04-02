# @cjsx React.DOM


GlobalState     = require('global_state/state')


# Stores
#
PinStore        = require('stores/pin_store')
UserStore       = require('stores/user_store.cursor')


# Components
#
PinComponent     = require('components/pinboards/pin')


NodeRepositioner = require('utils/node_repositioner')


# Exports
#
module.exports = React.createClass

  displayName: 'Pins'


  mixins: [GlobalState.mixin, GlobalState.query.mixin, NodeRepositioner.mixin]

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
  renderPin: (pin) ->
    <section className="cloud-column" key={ pin.get('uuid') }>
      <PinComponent uuid={ pin.get('uuid') } />
    </section>

  renderPins: ->
    @gatherPins().map(@renderPin).toArray()


  render: ->
    return null unless @isLoaded()

    <section className="pins cloud-columns cloud-columns-flex">
      { @renderPins() }
    </section>
