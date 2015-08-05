# @cjsx React.DOM

GlobalState = require('global_state/state')

PinStore    = require('stores/pin_store')
PinSyncAPI  = require('sync/pin_sync_api')

cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'StarInsightButton'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  # Specification
  #

  getInitialState: ->
    active: false
    sync:   true


  statics:
    queries:
      pin: ->
        """
          Pin {
            edges {
              is_mine,
              is_followed
            }
          }
        """

  fetch: (options = {}) ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.pin, force: options.force }).done (json) =>
      pin = PinStore.get(@props.pin).toJS()
      @setState
        pin:    pin
        sync:   false
        active: pin.is_followed


  # Events
  #

  handleClick: ->
    @setState
      sync: true

    PinSyncAPI[['follow', 'unfollow'][~~@state.active]](@props.pin).then => @fetch(force: true)


  # Lifecycle
  #

  componentWillMount: ->
    @cursor =
      is_followed: PinStore.cursor.items.cursor([@props.pin, 'is_followed'])


  componentDidMount: ->
    @fetch()


  onGlobalStateChange: ->
    @setState
      active: PinStore.get(@props.pin).get('is_followed')


  # Main Render
  #

  render: ->
    return null if @state.pin and @state.pin.is_mine

    className = cx
      'fa':         true
      'fa-star':    @state.active == true
      'fa-star-o':  @state.active == false
      'fa-spin':    @state.sync   == true

    <li className="star">
      <i className={ className } onClick={ @handleClick } />
    </li>
