# @cjsx React.DOM


# Components
#
PinboardsComponent  = require('components/pinboards/pinboards')


# Exports
#
module.exports = React.createClass

  displayName: 'PinboardsApp'

  render: ->
    <section className="pinboards-wrapper">
      <PinboardsComponent />
    </section>