# @cjsx React.DOM

# Components
#
PinComponent     = require('components/pinboards/pin')

NodeRepositioner = require('utils/node_repositioner')

# Exports
#
module.exports = React.createClass

  displayName: 'Pins'

  mixins: [NodeRepositioner.mixin]

  propTypes:
    pins:          React.PropTypes.array.isRequired
    onItemClick:   React.PropTypes.func

  # Renderers
  #
  renderPin: (pin) ->
    <section className="cloud-column" key={ pin.get('uuid') }>
      <PinComponent
        uuid          = { pin.get('uuid') }
        onClick       = { @props.onItemClick } />
    </section>

  renderPins: ->
    @props.pins.map(@renderPin)


  render: ->
    <section className="pins cloud-columns cloud-columns-flex">
      { @renderPins() }
    </section>
