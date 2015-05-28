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

  # Helpers
  #
  hasOneAuthor: ->
    !!@props.pins.reduce (memo, pin) ->
      if memo then (memo.get('user_id') == pin.get('user_id') && memo) else false


  # Renderers
  #
  renderPin: (pin, index) ->
    <section className="cloud-column" key={ pin.get('uuid') }>
      <PinComponent
        uuid          = { pin.get('uuid') }
        onClick       = { @props.onItemClick }
        showAuthor    = { !@hasOneAuthor() } />
    </section>

  renderPins: ->
    @props.pins.map(@renderPin)


  render: ->
    <section className="pins cloud-columns cloud-columns-flex">
      { @renderPins() }
    </section>
