# @cjsx React.DOM


GlobalState = require('global_state/state')
PinStore    = require('stores/pin_store')
UserStore   = require('stores/user_store.cursor')

PinForm     = require('components/form/pin_form')
Modal       = require('components/modal_stack')


# Utils
#
cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'PinButton'

  mixins: [GlobalState.mixin]

  propTypes: 
    uuid: React.PropTypes.string
    title: React.PropTypes.string.isRequired
    pinnable_id: React.PropTypes.string.isRequired
    pinnable_type: React.PropTypes.string.isRequired
    showCounter: React.PropTypes.bool

  getDefaultProps: ->
    showCounter: false
    cursor:
      pins:   PinStore.cursor.items
      user:   UserStore.me()

  getInitialState: ->
    @getStateFromStores()

  onGlobalStateChange: ->
    @setState @getStateFromStores()

  getStateFromStores: ->
    currentUserPin:     @currentUserPin()
    currentUserRepin:   @currentUserRepin()


  # Helpers
  #
  currentUserPin: ->
    if @props.uuid
      PinStore.cursor.items
        .find (pin) =>
          pin.get('uuid')     == @props.uuid                    and
          pin.get('user_id')  == @props.cursor.user.get('uuid')
    else
      PinStore.cursor.items
        .find (pin) =>
          pin.get('pinnable_id')      == @props.pinnable_id             and
          pin.get('pinnable_type')    == @props.pinnable_type           and
          pin.get('parent_id', null)  == null                           and
          pin.get('user_id')          == @props.cursor.user.get('uuid')

  currentUserRepin: ->
    return null unless @props.uuid

    PinStore.cursor.items
      .find (pin) =>
        pin.get('parent_id')  == @props.uuid                    and
        pin.get('user_id')    == @props.cursor.user.get('uuid')

  getPinsCount: ->
    PinStore.cursor.items
      .find (pin) =>
        pin.get('pinnable_id')      == @props.pinnable_id    and
        pin.get('pinnable_type')    == @props.pinnable_type  and
        pin.get('parent_id', null)  == null
      .size  


  # Handlers
  #
  handleClick: (event) ->
    if @state.currentUserPin
      PinStore.destroy(@state.currentUserPin.get('uuid')) if confirm('Are you sure?')
    else if @state.currentUserRepin
      PinStore.destroy(@state.currentUserRepin.get('uuid')) if confirm('Are you sure?')
    else
      Modal.show(@renderPinForm())


  # Renderers
  #
  renderPinForm: ->
    <PinForm
      title         = { @props.title }
      parent_id     = { @props.uuid }
      pinnable_id   = { @props.pinnable_id }
      pinnable_type = { @props.pinnable_type }
      onDone        = { Modal.hide }
      onCancel      = { Modal.hide }
    />

  renderCounter: ->
    return null unless @props.showCounter

    <span>{ @getPinsCount() }</span>


  render: ->
    return null unless @props.cursor.user.get('uuid')

    classList = cx
      active: !!@state.currentUserPin or !!@state.currentUserRepin
      'with-counter': @props.showCounter

    <li className={ classList } onClick={ @handleClick }>
      <i className="fa fa-thumb-tack" />
      { @renderCounter() }
    </li>
