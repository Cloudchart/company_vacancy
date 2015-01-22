# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinStore      = require('stores/pin_store')


# Components
#

PinnablePreviewComponents =
  Post: require('components/pinnable/post_preview')


TransparentPinComponent = React.createClass

  render: ->
    <li className="pin transparent">
      <i className="fa fa-spinner fa-spin" />
    </li>


# Exports
#
module.exports = React.createClass

  displayName: 'Pin'
  

  mixins: [GlobalState.mixin]
  
  
  handleUnpinClick: ->
    if confirm('Are you sure?')
      PinStore.destroy(@props.uuid)
  
  
  onGlobalStateChange: ->
    @setState
      refreshed_at: + new Date
  
  
  renderPinPreview: ->
    pin       = @props.cursor.deref()
    component = PinnablePreviewComponents[pin.get('pinnable_type')]
    component
      pin:          pin
      uuid:         pin.get('pinnable_id')
      cursor:       component.getCursor(pin)
      onUnpinClick: @handleUnpinClick
      skipBlocks:   @props.skipBlocks
  
  
  render: ->
    return null unless @props.cursor.deref()
    
    if @props.cursor.get('transparent') == true
      <TransparentPinComponent />
    else
      <li className="pin">
        { @renderPinPreview() }
      </li>
