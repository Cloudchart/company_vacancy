# @cjsx React.DOM

GlobalState     = require('global_state/state')

# Stores
#
PinboardStore   = require('stores/pinboard_store')
PinStore        = require('stores/pin_store')


# Components
#
PinboardComponent = require('components/pinboards/pinboard')

PinComponent  = require('components/pinnable/pin')


PinboardListItemComponent = React.createClass


  displayName: 'PinboardListItem'
  
  
  mixins: [GlobalState.mixin]
  
  
  getHeader: ->
    <header>
      <span className="title">{ @state.pinboard.get('title') }</span>
      <span className="count">{ @state.pins.count() } { if @state.pins.size == 1 then 'pin' else 'pins' }</span>
    </header>
  
  
  gatherPins: ->
    Immutable.Seq(@state.pins)
      .map (pin) =>
        uuid = pin.get('uuid')
        PinComponent({ key: uuid, uuid: uuid, cursor: @props.cursor.pins.cursor(uuid), skipBlocks: true })
  
  
  getPinPreviews: ->
    return null if @state.pins.size == 0
    
    <ul className="pins">
      <li className="link">
        <i className="fa fa-angle-right" onClick={ @props.handleLinkClick } />
      </li>
      { @gatherPins().take(1).toArray() }
    </ul>
  
  
  preloadTransparentPins: (count) ->
    partial_pins_ids = @state.pins.take(count).filter((pin) -> pin.get('--part--') == true).keySeq()

    return if partial_pins_ids.size == 0
    
    PinStore.fetchAll({ ids: partial_pins_ids.toArray(), relations: 'all' })
  
  
  getStateFromStores: ->
    pinboard:   @props.cursor.pinboards.get(@props.uuid)
    pins:       PinStore.filterByPinboardId(@props.uuid)
  
  
  onGlobalStateChange: ->
    @setState @getStateFromStores()
    @preloadTransparentPins(1)
  
  
  componentDidMount: ->
    @preloadTransparentPins(1)
  

  getDefaultProps: ->
    cursor:
      pinboards:  PinboardStore.cursor.items
      pins:       PinStore.cursor.items
  

  getInitialState: ->
    @getStateFromStores()
  

  render: ->
    return null unless @state.pinboard
    
    <li className="pinboard">
      { @getHeader() }
      { @getPinPreviews() }
    </li>


# Exports
#
module.exports = React.createClass


  displayName: 'PinboardsApp'


  mixins: [GlobalState.mixin]


  gatherPinboards: ->
    @props.cursor.pinboards.deref(PinboardStore.empty)

      .sortBy (pinboard) ->
        pinboard.get('title')

      .map    (pinboard) =>
        uuid = pinboard.get('uuid')
        PinboardListItemComponent({ key: uuid, uuid: uuid, handleLinkClick: @handleForwardClick.bind(null, uuid) })
  

  handleForwardClick: (id, event) ->
    event.preventDefault()

    url = @props.cursor.pinboards.getIn([id, 'url'])

    if history.pushState
      @setState({ uuid: id })
      history.pushState(null, null, url)
    else
      location.href = url
  
  
  handleBackClick: (event) ->
    event.preventDefault()

    if history.length > 2
      @setState({ uuid: null })
      history.back()
    else
      location.href = '/pinboards'
  
  
  onGlobalStateChange: ->
    @setState
      refreshed_at: + new Date


  componentDidMount: ->
    PinboardStore.fetchAll()
  
  
  getDefaultProps: ->
    cursor:
      pinboards:  PinboardStore.cursor.items
  
  getInitialState: ->
    uuid: @props.uuid


  render: ->
    if @state.uuid
      PinboardComponent({ cursor: PinboardComponent.getCursor(@state.uuid), uuid: @state.uuid, onClick: @handleBackClick })
    else
      <ul className="pinboards">
        { @gatherPinboards().toArray() }
      </ul>
