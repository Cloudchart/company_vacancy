# @cjsx React.DOM

GlobalState = require('global_state/state')

PinStore    = require('stores/pin_store')
PinSyncAPI  = require('sync/pin_sync_api')

cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'StarInsightButton'

  mixins: [GlobalState.query.mixin]

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
              is_followed
            }
          }
        """

  fetch: (options = {}) ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.pin, force: options.force }).done (json) =>
      PinStore.get(@props.pin)
      @setState
        sync:   false
        active: PinStore.get(@props.pin).get('is_followed')


  # Events
  #

  handleClick: ->
    @setState
      sync: true

    PinSyncAPI[['follow', 'unfollow'][~~@state.active]](@props.pin).then => @fetch(force: true)




  # Lifecycle
  #

  componentDidMount: ->
    @fetch()


  # Main Render
  #

  render: ->

    className = cx
      'fa':         true
      'fa-star':    @state.active == true
      'fa-star-o':  @state.active == false
      'fa-spin':    @state.sync   == true

    <li className="star">
      <i className={ className } onClick={ @handleClick } />
    </li>
