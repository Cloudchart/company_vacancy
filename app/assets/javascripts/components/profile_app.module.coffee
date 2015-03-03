# @cjsx React.DOM


UserComponent      = require('components/users/user')
PinboardsComponent = require('components/pinboards/pinboards')


module.exports = React.createClass

  displayName: 'ProfileApp'

  propTypes:
    uuid:     React.PropTypes.string.isRequired
    readOnly: React.PropTypes.bool

  getDefaultProps: ->
    readOnly: false


  render: ->
    <div>
      <UserComponent 
        uuid     = { @props.uuid }
        readOnly = { @props.readOnly } />
      <PinboardsComponent
        uuid = { @props.uuid } />
    </div>
