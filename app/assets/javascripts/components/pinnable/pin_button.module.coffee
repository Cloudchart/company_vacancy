# @cjsx React.DOM


GlobalState     = require('global_state/state')
PinStore        = require('stores/pin_store')
UserStore       = require('stores/user_store.cursor')
TokenStore      = require('stores/token_store.cursor')

PinForm         = require('components/form/pin_form')
Modal           = require('components/modal_stack')
StandardButton  = require('components/form/buttons').StandardButton
Hotzone         = require('components/shared/hotzone')


# Utils
#
cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'PinButton'

  mixins: [GlobalState.mixin]

  propTypes: 
    uuid:          React.PropTypes.string
    title:         React.PropTypes.string
    pinnable_id:   React.PropTypes.string
    pinnable_type: React.PropTypes.string
    asTextButton:  React.PropTypes.bool
    showHotzone:   React.PropTypes.bool

  getDefaultProps: ->
    asTextButton: false
    showHotzone:  false
    cursor:
      pins:   PinStore.cursor.items
      user:   UserStore.me()

  getInitialState: ->
    _.extend loaders: Immutable.Map(), clicked: false,
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
      .filter (pin) =>
        pin.get('pinnable_id')      == @props.pinnable_id    and
        pin.get('pinnable_type')    == @props.pinnable_type  and
        (pin.get('parent_id', null)  == null || pin.get('is_suggestion'))
      .size

  getRepinsCount: ->
    PinStore.cursor.items
      .filter (pin) => pin.get('parent_id') == @props.uuid
      .size

  getCount: ->
    if @props.uuid then @getRepinsCount() else @getPinsCount()

  isClickable: ->
    @props.pinnable_id || @currentUserRepin() || @currentUserPin()

  isActive: ->
    !!@state.currentUserPin || !!@state.currentUserRepin


  # Handlers
  #
  handleClick: (event) ->
    return null unless @isClickable()

    event.preventDefault()
    event.stopPropagation()

    @setState(clicked: true)

    if @state.currentUserPin
      Modal.show(@renderEditPinForm(@state.currentUserPin.get('uuid')))
    else if @state.currentUserRepin
      Modal.show(@renderEditPinForm(@state.currentUserRepin.get('uuid')))
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
      onCancel      = { Modal.hide } />

  renderEditPinForm: (uuid) ->
    <PinForm
      uuid          = { uuid }
      onDone        = { Modal.hide }
      onCancel      = { Modal.hide } />

  renderCounter: ->
    return null unless (count = @getCount()) > 0 && @isActive()

    <span>{ count }</span>

  renderText: ->
    return null if @isActive()

    "Save"

  renderHotzone: ->
    return null unless @props.showHotzone && !@state.clicked

    <Hotzone />


  render: ->
    return null unless @props.cursor.user.get('uuid') && @props.cursor.user.get('twitter')

    classList = cx
      active:         @isActive()
      'with-content': true
      'pin-button':   true
      'disabled':     !@isClickable()

    unless @props.asTextButton
      <li className={ classList } onClick={ @handleClick }>
        <i className="fa fa-thumb-tack" />
        { @renderCounter() }
        { @renderText() }
        { @renderHotzone() }
      </li>
    else
      <StandardButton 
        className = "cc"
        iconClass = "fa fa-thumb-tack"
        onClick   = { @handleClick }
        text      = "Be the first to leave an insight" />
