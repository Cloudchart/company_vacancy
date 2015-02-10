# @cjsx React.DOM

# Components
#
PinsComponent       = require('components/pinboards/pins')
PinboardsComponent  = require('components/pinboards/pinboards')

# Exports
#
module.exports = React.createClass

  displayName: 'PinboardsApp'

  getInitialState: ->
    uuid: @props.uuid


  render: ->
    if @state.uuid
      <PinsComponent uuid={ @state.uuid } />
    else
      <PinboardsComponent />
