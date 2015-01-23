# @cjsx React.DOM

GlobalState = require('global_state/state')


# Stores
#
PinboardStore = require('stores/pinboard_store')
PinStore      = require('stores/pin_store')


# Components
#
PinComponent = require('components/pinnable/pin')


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
  
  
  renderHeader: (pins) ->
    <header>
      <a href="/pinboards" className="back" onClick={ @props.onClick }>
        <i className="fa fa-angle-left" />
      </a>
      <span className="title">{ @props.cursor.pinboard.get('title') }</span>
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
      .filter (pin) -> pin.get('transparent') == true
      .keySeq()
    
    return if unloaded_pins_ids.count() == 0
    
    PinStore.fetchAll({ ids: unloaded_pins_ids.toArray(), relations: 'all' })
  
  
  componentDidUpdate: ->
    @preloadTransparentPins()
  

  componentDidMount: ->
    PinboardStore.fetchAll() unless @props.cursor.pinboard.deref()
    @preloadTransparentPins()
  
  
  onGlobalStateChange: ->
    @setState
      refreshed_at: + new Date
  
  
  render: ->
    return null unless @props.cursor.pinboard.deref()
    
    pins = @gatherPins()
    
    <article className="pinboard">
      { @renderHeader(pins) }
      
      <ul className="pins">
        { @renderPins(pins).toArray() }
      </ul>
    </article>
