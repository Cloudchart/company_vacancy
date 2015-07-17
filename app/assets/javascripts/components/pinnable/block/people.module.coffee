# @cjsx React.DOM

# Components
#

Human = require('components/human')


# Exports
#
module.exports = React.createClass


  displayName: 'People'

  propTypes:
    ids:            React.PropTypes.instanceOf(Immutable.Seq)
    showOccupation: React.PropTypes.bool
    showLink:       React.PropTypes.bool

  getDefaultProps: ->
    showOccupation: true
    showLink:       true

  renderPerson: (id) ->
    <Human 
      type           = "person"
      key            = { id }
      showLink       = { @props.showLink }
      showOccupation = { @props.showOccupation }
      uuid           = { id } />


  render: ->
    return null unless @props.ids.size > 0

    <section className="people">
      { @props.ids.map(@renderPerson).toArray() }
    </section>
