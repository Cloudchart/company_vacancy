# @cjsx React.DOM

GlobalState = require('global_state/state')


# Stores
#
PinboardStore = require('stores/pinboard_store')
PinStore      = require('stores/pin_store')


# Actions
#
ModalActions  = require('actions/modal_actions')


# Components
#
PinComponent          = require('components/pinnable/pin')
SettingsFormComponent = require('components/pinboards/settings_form')


# Exports
#
module.exports = React.createClass


  displayName: 'Pinboard'
  
  
  mixins: [GlobalState.mixin]
  
  
  statics:
    getCursor: (uuid) ->
      pinboard: PinboardStore.cursor.items.cursor(uuid)
      pins:     PinStore.cursor.items
  
  
  gatherPins: ->
    PinStore
      .filterByPinboardId(@props.uuid)
      .sortBy (pin) -> pin.get('created_at')
      .reverse()
  
  
  renderSettingsButton: ->
    if @props.cursor.pinboard.get('user_id') == @props.currentUserId
      <i className="fa fa-cog settings" onClick={ @handleSettingsLinkClick } />
  
  
  renderHeader: (pins) ->
    <header>
      <a href="/pinboards" className="back" onClick={ @props.onClick }>
        <i className="fa fa-angle-left" />
      </a>
      <span className="title">{ @props.cursor.pinboard.get('title') }</span>
      { @renderSettingsButton() }
      <span className="count">{ pins.size } { if pins.size == 1 then 'pin' else 'pins' }</span>
    </header>
  
  
  renderPins: (pins) ->
    pins
      .map (pin) =>
        uuid = pin.get('uuid')
        PinComponent({ key: uuid, uuid: uuid, cursor: @props.cursor.pins.cursor(uuid) })
      .valueSeq()
    
  
  
  preloadTransparentPins: ->
    unloaded_pins_ids = @gatherPins()
      .filter (pin) -> pin.get('--part--') == true
      .keySeq()
    
    return if unloaded_pins_ids.count() == 0
    
    PinStore.fetchAll({ ids: unloaded_pins_ids.toArray(), relations: 'all' })
  
  
  handleSettingsLinkClick: (event) ->
    event.preventDefault()
    ModalActions.show(<SettingsFormComponent cursor={ @props.cursor.pinboard } onCancel={ ModalActions.hide } />)
  
  
  componentDidUpdate: ->
    @preloadTransparentPins()
  

  componentDidMount: ->
    PinboardStore.fetchAll() unless @props.cursor.pinboard.deref()
    @preloadTransparentPins()
  
  
  onGlobalStateChange: ->
    @setState
      refreshed_at: + new Date
  
  
  getDefaultProps: ->
    currentUserId: if node = document.querySelector('meta[name="user-id"]') then node.getAttribute('content')
  
  
  render: ->
    return null unless @props.cursor.pinboard.deref()
    
    pins = @gatherPins()
    
    <article className="pinboard">
      { @renderHeader(pins) }
      
      <ul className="pins">
        { @renderPins(pins).toArray() }
      </ul>
    </article>
