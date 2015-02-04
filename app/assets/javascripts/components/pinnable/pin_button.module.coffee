# @cjsx React.DOM


GlobalState = require('global_state/state')
PinStore    = require('stores/pin_store')
UserStore   = require('stores/user_store.cursor')

PinForm     = require('components/form/pin_form')
Modal       = require('components/modal_stack')


# Utils
#
cx = React.addons.classSet


findPinForUser = (parent_id, pinnable_id, pinnable_type, user_id) ->
  return null if parent_id

  PinStore.cursor.items.find (pin) ->
    pin.get('parent_id', null)  is null           and
    pin.get('pinnable_id')      is pinnable_id    and
    pin.get('pinnable_type')    is pinnable_type  and
    pin.get('user_id')          is user_id


findRepinForUser = (parent_id, user_id) ->
  return null unless parent_id

  PinStore.cursor.items.find (pin) ->
    pin.get('parent_id')  is parent_id  and
    pin.get('user_id')    is user_id


# Exports
#
module.exports = React.createClass

  displayName: 'PinButton'


  mixins: [GlobalState.mixin]


  handleClick: (event) ->
    if !!@state.currentUserPin
      PinStore.destroy(@state.currentUserPin.get('uuid')) if confirm('Are you sure?')
    else if !!@state.currentUserRepin
      PinStore.destroy(@state.currentUserRepin.get('uuid')) if confirm('Are you sure?')
    else
      Modal.show(@renderPinForm())


  onGlobalStateChange: ->
    @setState @getStateFromStores()


  getStateFromStores: ->
    currentUserPin:     findPinForUser(@props.parent_id, @props.pinnable_id, @props.pinnable_type, @props.cursor.user.get('uuid'))
    currentUserRepin:   findRepinForUser(@props.parent_id, @props.cursor.user.get('uuid'))


  getDefaultProps: ->
    cursor:
      pins:   PinStore.cursor.items
      user:   UserStore.currentUserCursor()


  getInitialState: ->
    @getStateFromStores()


  renderPinForm: ->
    <PinForm
      title         = { @props.title }
      parent_id     = { @props.parent_id }
      pinnable_id   = { @props.pinnable_id }
      pinnable_type = { @props.pinnable_type }
      onDone        = { Modal.hide }
      onCancel      = { Modal.hide }
    />


  render: ->
    return null unless @props.cursor.user.get('uuid')

    classList = cx
      active: !!@state.currentUserPin or !!@state.currentUserRepin

    <li className={ classList } onClick={ @handleClick }>
      <i className="fa fa-thumb-tack" />
    </li>
