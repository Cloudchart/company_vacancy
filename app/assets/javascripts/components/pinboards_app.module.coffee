# @cjsx React.DOM


# Components
#
PinsComponent       = require('components/pinboards/pins')


# Exports
#
module.exports = React.createClass

  displayName: 'PinboardsApp'

  render: ->
    <PinsComponent />
