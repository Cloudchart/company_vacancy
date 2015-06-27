# @cjsx React.DOM


GlobalState     = require('global_state/state')
PinStore        = require('stores/pin_store')
UserStore       = require('stores/user_store.cursor')
TokenStore      = require('stores/token_store.cursor')

PinForm         = require('components/form/pin_form')
Modal           = require('components/modal_stack')
StandardButton  = require('components/form/buttons').StandardButton
Hotzone         = require('components/shared/hotzone')

HotzoneCursor   = GlobalState.cursor(['meta', 'insight', 'hotzone'])

Automated = false

# Utils
#
cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'PinButton'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      viewer: ->

        """
          Viewer {
            tokens
          }
        """

  propTypes:
    uuid:          React.PropTypes.string
    title:         React.PropTypes.string
    label:         React.PropTypes.string
    pinnable_id:   React.PropTypes.string
    pinnable_type: React.PropTypes.string
    asTextButton:  React.PropTypes.bool
    showHotzone:   React.PropTypes.bool

  getDefaultProps: ->
    asTextButton: false
    showHotzone:  true
    label:        'Save'
    cursor:
      pins:    PinStore.cursor.items
      tokens:  TokenStore.cursor.items
      hotzone: HotzoneCursor
      user:    UserStore.me()

  getInitialState: ->
    _.extend loaders: Immutable.Map(), clicked: false,
      @getStateFromStores()

  onGlobalStateChange: ->
    @setState @getStateFromStores()

  getStateFromStores: ->
    currentUserPin:     @currentUserPin()
    currentUserRepin:   @currentUserRepin()

  fetch: (id) ->
    GlobalState.fetch(@getQuery('viewer'))


  # Helpers
  #

  performAutomation: ->
    uuid = Cookies.get('action-pin')
    if uuid and uuid == @props.uuid
      return if Automated
      Automated = true
      Cookies.remove('action-pin')
      @showModal()

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

  shouldShowHotzone: ->
    @props.showHotzone && (!!TokenStore.findByUserAndName(@props.cursor.user, 'insight_tour') || location.search == '?hotzone=true')

  getPinButtonKey: ->
    @props.pinnable_id + @props.uuid

  showHotzone: ->
    @shouldShowHotzone() && (HotzoneCursor.deref(false) == @getPinButtonKey())

  isHotzoneShown: ->
    HotzoneCursor.deref(false)

  checkVisibility: ->
    return null unless @shouldShowHotzone() && !@isHotzoneShown()

    difference = $(window).scrollTop() + $(window).height() - $(@getDOMNode()).offset().top

    if difference > 0 && difference < $(window).height() && $(@getDOMNode()).offset().left > 0
      HotzoneCursor.update (data) => @getPinButtonKey()


  # Handlers
  #
  handleClick: (event) ->
    return null unless @isClickable()

    event.preventDefault()
    event.stopPropagation()

    unless @props.cursor.user.get('twitter', false)
      Cookies.set('action-pin', @props.uuid)
      location.href = '/auth/twitter'
      return null

    @showModal()



  showModal: ->
    @setState(clicked: true)

    if @state.currentUserPin
      Modal.show(@renderEditPinForm(@state.currentUserPin.get('uuid')))
    else if @state.currentUserRepin
      Modal.show(@renderEditPinForm(@state.currentUserRepin.get('uuid')))
    else
      Modal.show(@renderPinForm())



  # Lifecycle methods
  #
  componentWillMount: ->
    @fetch()

  componentDidMount: ->
    @timer = false

    setTimeout @checkVisibility, 100

    window.addEventListener "scroll", @checkVisibility
    window.addEventListener "resize", @checkVisibility

    @performAutomation()

  componentWillUnmount: ->
    window.removeEventListener "scroll", @checkVisibility
    window.removeEventListener "resize", @checkVisibility


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

    @props.label

  renderHotzone: ->
    return null unless @showHotzone() && !@state.clicked && @isClickable()

    <Hotzone />


  render: ->
    return null unless @props.cursor.user.get('uuid') #&& @props.cursor.user.get('twitter')

    classList = cx
      active:         false
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
        text      = "Be the first to add an insight" />
