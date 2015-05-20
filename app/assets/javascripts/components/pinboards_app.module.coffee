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
      <header className="cloud-columns cloud-columns-flex">Your boards</header>
      <PinboardsComponent />
    </section>