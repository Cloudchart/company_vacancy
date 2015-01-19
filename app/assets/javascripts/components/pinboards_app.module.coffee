# @cjsx React.DOM

Dispatcher      = require('dispatcher/dispatcher')
GlobalState     = require('global_state/state')

# Stores
#
PinboardStore   = require('stores/pinboard_store')
PinStore        = require('stores/pin_store')

# Components
#
PinnableComponents =
  Post: require('components/pinnable/post')


# Utils
#
pinboardsSorter = (item) -> item.get('title')


lastPinForPinboard = (pinboard, pins) ->
  pins
    .filter((pin) -> pin.get('pinboard_id') == pinboard.get('uuid'))
    .sortBy((pin) -> pin.get('created_at'))
    .last()


pinMapper = (item, pinboard) ->
  <div className="pin-preview">
    { PinnableComponents[item.get('pinnable_type')]({
      uuid:             item.get('pinnable_id')
      content:          item.get('content') 
      onPinButtonClick: -> PinStore.destroy(item.get('uuid')) if confirm('Are you sure?')
    }) }
    <button className="dive" onClick={ -> location.href = pinboard.get('url') }><i className="fa fa-angle-right" /></button>
  </div>


pinboardsMapper = (item) ->
  pinboard_pins = @props.cursor.pins.deref(PinStore.empty).filter((pin) -> pin.get('pinboard_id') == item.get('uuid'))
  
  last_pin    = pinboard_pins.sortBy((pin) -> pin.get('created_at')).last()
  last_pin    = pinMapper(last_pin, item) if last_pin
  
  <li key={item.get('uuid')}>
    <header>
      <span className="title">{ item.get('title') }</span>
      <span className="count">{ pinboard_pins.size } { if pinboard_pins.size == 1 then 'pin' else 'pins' }</span>
    </header>
    
    { last_pin }

  </li>


# Exports
#
module.exports = React.createClass


  displayName: 'PinboardsApp'


  mixins: [GlobalState.mixin]


  gatherPinboards: ->
    @props.cursor.pinboards.deref(PinboardStore.empty)
      .sortBy pinboardsSorter
      .map    pinboardsMapper.bind(@)
  
  
  getPinboard: ->
    pinboard = @props.cursor.pinboards.get(@props.uuid)
  
  
  gatherPins: ->
    pinboard = @props.cursor.pinboards.get(@props.uuid)
    
    @props.cursor.pins.deref(PinStore.empty)
      .valueSeq()
      .filter((pin) => pin.get('pinboard_id') == @props.uuid)
      .sortBy((pin) => pin.get('created_at'))
      .reverse()
      .map (pin) ->
        <li key={ pin.get('uuid') } className="pin-preview">
          { PinnableComponents[pin.get('pinnable_type')]({
            uuid:             pin.get('pinnable_id')
            content:          pin.get('content') 
            onPinButtonClick: -> PinStore.destroy(pin.get('uuid')) if confirm('Are you sure?')
          }) }
        </li>


  onGlobalStateChange: ->
    @setState
      refreshed_at: + new Date


  componentDidMount: ->
    PinboardStore.fetchAll()
    PinStore.fetchAll()
  
  
  getDefaultProps: ->
    cursor:
      pinboards:  PinboardStore.cursor.items
      pins:       PinStore.cursor.items


  render: ->
    if @props.uuid
      pinboard  = @getPinboard()
      pins      = @gatherPins()
      
      return null unless pinboard
      
      <article className="pinboard">
        <header>
          <span className="title">{ pinboard.get('title') }</span>
        </header>
        
        <section className="pins">
          <ul className="left">
            { pins.filter((pin, i) -> i % 2 == 0).toArray() }
          </ul>
          <ul className="right">
            { pins.filter((pin, i) -> i % 2 == 1).toArray() }
          </ul>
        </section>
      </article>
      
    else
      pinboards = @gatherPinboards()

      <ul className="pinboards">
        { pinboards.toArray() }
      </ul>
