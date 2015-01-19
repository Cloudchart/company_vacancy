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


pinMapper = (item) ->
  <div className="pin-preview">
    { PinnableComponents[item.get('pinnable_type')]({
      uuid:             item.get('pinnable_id')
      content:          item.get('content') 
      onPinButtonClick: -> PinStore.destroy(item.get('uuid')) if confirm('Are you sure?')
    }) }
  </div>


pinboardsMapper = (item) ->
  pinboard_pins = @props.cursor.pins.deref(PinStore.empty).filter((pin) -> pin.get('pinboard_id') == item.get('uuid'))
  
  last_pin    = pinboard_pins.sortBy((pin) -> pin.get('created_at')).last()
  last_pin    = pinMapper(last_pin) if last_pin
  
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


  onGlobalStateChange: ->
    @setState
      refreshed_at: + new Date


  componentDidMount: ->
    PinboardStore.fetchAll()
    PinStore.fetchAll({ complete: true })
  
  
  getDefaultProps: ->
    cursor:
      pinboards:  PinboardStore.cursor.items
      pins:       PinStore.cursor.items


  render: ->
    pinboards = @gatherPinboards()

    <ul className="pinboards">
      { pinboards.toArray() }
    </ul>
