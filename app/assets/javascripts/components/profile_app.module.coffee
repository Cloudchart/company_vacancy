# @cjsx React.DOM


UserComponent = require('components/users/user')


module.exports = React.createClass

  displayName: 'ProfileApp'

  propTypes:
    uuid:     React.PropTypes.string.isRequired
    readOnly: React.PropTypes.bool

  getDefaultProps: ->
    readOnly: false


  render: ->
    <UserComponent 
      uuid     = { @props.uuid }
      readOnly = { @props.readOnly } />
