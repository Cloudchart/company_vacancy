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

      viewer_pins: ->
        """
          Viewer {
            pins {
              #{PinComponent.getQuery('pin')}
            }
          }
        """

      user_pins: ->
        """
          User {
            pins {
              #{PinComponent.getQuery('pin')}
            }
          }
        """

  propTypes:
    uuid: React.PropTypes.string

  getDefaultProps: ->
    uuid: null

  getInitialState: ->
    loaders: Immutable.Map()


  # Helpers
  #
  fetch: ->
    if @props.uuid
      promise = GlobalState.fetch(@getQuery('user_pins'), id: @props.uuid)
    else
      promise = GlobalState.fetch(@getQuery('viewer_pins'))

    promise.then =>
      @setState
        loaders: @state.loaders.set('pins', true)

  isLoaded: ->
    @state.loaders.get('pins') && @cursor.user.deref(false)

  getUserId: ->
    if @props.uuid then @props.uuid else @cursor.user.get('uuid')

  gatherPins: ->
    @cursor.pins
      .filter (pin) => pin.get('user_id') == @getUserId() && pin.get('pinnable_id')
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

    <section className="pins cloud-columns cloud-columns-flex">
      { @renderPins() }
    </section>
