# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinboardStore = require('stores/pinboard_store')
PinStore      = require('stores/pin_store')
UserStore     = require('stores/user_store.cursor')


# Components
#
PinComponent  = require('components/pinboards/pin')
PostComponent = require('components/pinnable/post')


# Exports
#
module.exports = React.createClass

  displayName: 'Pins'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      pins: ->
        """
          Viewer {
            pins {
              #{PinComponent.getQuery('pin')}
            }
          }
        """


  # Helpers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pins'))

  isLoaded: ->
    @cursor.pins.deref(false) && @cursor.user.deref(false)

  gatherPins: ->
    @cursor.pins
      .filter (pin) => pin.get('user_id') == @cursor.user.get('uuid') && pin.get('pinnable_id')
      .valueSeq()
      .sortBy (pin) -> pin.get('created_at')
      .reverse()


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      pins: PinStore.cursor.items
      user: UserStore.me()

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

    <section className="cloud-columns cloud-columns-flex">
      { @renderPins() }
    </section>
