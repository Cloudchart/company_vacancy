# @cjsx React.DOM


GlobalState     = require('global_state/state')
PinStore        = require('stores/pin_store')
UserStore       = require('stores/user_store.cursor')
TokenStore      = require('stores/token_store.cursor')

PinForm         = require('components/form/pin_form')
Modal           = require('components/modal_stack')
StandardButton  = require('components/form/buttons').StandardButton


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

  getDefaultProps: ->
    asTextButton: false
    cursor:
      pins:   PinStore.cursor.items
      user:   UserStore.me()

  getInitialState: ->
    _.extend loaders: Immutable.Map(),
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


  # Handlers
  #
  handleClick: (event) ->
    event.preventDefault()
    event.stopPropagation()

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
    return null unless (count = @getCount()) > 0

    <span>{ count }</span>


  render: ->
    return null unless @props.cursor.user.get('uuid') && @props.cursor.user.get('twitter')

    classList = cx
      active: !!@state.currentUserPin or !!@state.currentUserRepin
      'with-counter': (@getCount() > 0)

    unless @props.asTextButton
      <li className={ classList } onClick={ @handleClick }>
        <i className="fa fa-thumb-tack" />
        { @renderCounter() }
      </li>
    else
      <StandardButton 
        className = "cc"
        iconClass = "fa fa-thumb-tack"
        onClick   = { @handleClick }
        text      = "Be the first to leave an insight" />
