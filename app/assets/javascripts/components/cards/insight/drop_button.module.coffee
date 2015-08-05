# @cjsx React.DOM

GlobalState = require('global_state/state')


PinStore      = require('stores/pin_store')
PinboardStore = require('stores/pinboard_store')

# PinSyncAPI    = require('sync/pin_sync_api')


# Utils
#
cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'InsightDropButton'

  # Specification
  #

  propTypes:
    pin:    React.PropTypes.string.isRequired
    scope:  React.PropTypes.string.isRequired

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  getDefaultProps: ->
    sync:   false


  getInitialState: ->
    mine: false


  statics:
    queries:
      pin: ->
        """
          Pin {
            pinboard {
              edges {
                is_editable
              }
            },
            edges {
              is_mine
            }
          }
        """

      pinboard: ->
        """
          Pinboard {
            edges {
              pins_ids
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.pin }).then =>
      pin       = PinStore.get(@props.pin).toJS()
      pinboard  = PinboardStore.get(pin.pinboard_id).toJS() if pin.pinboard_id
      @setState
        pin:        pin
        pinboard:   pinboard


  # Events
  #

  handleClick: (event) ->
    return unless confirm "Are you sure?"

    PinStore.destroy(@props.pin).then =>
      GlobalState.fetch(@getQuery('pinboard'), { id: @state.pinboard.id, force: true }) if @state.pinboard


  # Lifecycle
  #

  componentDidMount: ->
    @fetch()



  # Main Render
  #

  render: ->
    return null unless @props.scope == 'pinboard'

    return null unless @state.pin

    if @state.pinboard
      return null unless @state.pinboard.is_editable
    else
      return null unless @state.pin.is_mine

    className = cx
      'drop':       true

    iconClassName = cx
      'fa':         true
      'fa-remove':  true
      'fa-spin':    @props.sync   == true

    <li className={ className }>
      <i className={ iconClassName } onClick={ @handleClick } />
    </li>
