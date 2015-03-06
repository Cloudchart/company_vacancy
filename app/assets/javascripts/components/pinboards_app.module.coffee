# @cjsx React.DOM


# Components
#
PinsComponent       = require('components/pinboards/pins')
PinboardsComponent  = require('components/pinboards/pinboards')
SettingsComponent   = require('components/pinboards/settings')


# Exports
#
module.exports = React.createClass

  displayName: 'PinboardsApp'

  getInitialState: ->
    uuid: @props.uuid


  render: ->
    if @state.uuid
      if @props.action == 'settings'
        <SettingsComponent uuid={ @state.uuid } />
      else
        <PinsComponent uuid={ @state.uuid } />
    else
      <PinboardsComponent />
