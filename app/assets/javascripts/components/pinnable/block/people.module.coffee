# @cjsx React.DOM

# Components
#

Human = require('components/human')


# Exports
#
module.exports = React.createClass


  displayName: 'People'

  propTypes:
    items: React.PropTypes.instanceOf(Immutable.Seq)
    showOccupation: React.PropTypes.bool

  getDefaultProps: ->
    showOccupation: true

  renderPerson: (item) ->
    <Human 
      type           = "person"
      key            = { item.get('uuid') }
      showOccupation = { @props.showOccupation }
      uuid           = { item.get('uuid') } />


  render: ->
    return null unless @props.items.size > 0

    <section className="people">
      { @props.items.map(@renderPerson).toArray() }
    </section>
