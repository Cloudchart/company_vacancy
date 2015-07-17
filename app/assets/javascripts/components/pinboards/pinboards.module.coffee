# @cjsx React.DOM


PinboardComponent  = require('components/pinboards/pinboard')

NodeRepositioner   = require('utils/node_repositioner')


# Exports
#
module.exports = React.createClass


  displayName: 'Pinboards'

  mixins: [NodeRepositioner.mixin]

  propTypes:
    pinboards: React.PropTypes.array.isRequired
    user_id:   React.PropTypes.string


  # Renderers
  #
  renderPinboard: (pinboard) ->
    <section className="cloud-column" key={ pinboard.get('uuid') }>
      <PinboardComponent 
        uuid    = { pinboard.get('uuid') }
        user_id = { @props.user_id } />
    </section>

  renderPinboards: ->
    @props.pinboards.map(@renderPinboard)


  render: ->
    <section className="pinboards cloud-columns cloud-columns-flex">
      { @renderPinboards() }
    </section>
