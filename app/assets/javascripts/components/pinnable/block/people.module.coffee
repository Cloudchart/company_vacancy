# @cjsx React.DOM

# Components
#

Human = require('components/human')


# Exports
#
module.exports = React.createClass


  displayName: 'People'

  propTypes:
    ids: React.PropTypes.instanceOf(Immutable.Seq)
    showOccupation: React.PropTypes.bool

  getDefaultProps: ->
    showOccupation: true

  renderPerson: (id) ->
    <Human 
      type           = "person"
      key            = { id }
      showOccupation = { @props.showOccupation }
      uuid           = { id } />


  render: ->
    return null unless @props.ids.size > 0

    <section className="people">
      { @props.ids.map(@renderPerson).toArray() }
    </section>
