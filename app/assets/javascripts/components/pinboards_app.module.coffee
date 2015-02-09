# @cjsx React.DOM

# Components
#
Pinboard  = require('components/pinboards/pinboard')
Pinboards = require('components/pinboards/pinboards')

# Exports
#
module.exports = React.createClass

  displayName: 'PinboardsApp'

  render: ->
    if @props.uuid
      <Pinboard uuid={ @props.uuid } mode="show" />
    else
      <Pinboards />
