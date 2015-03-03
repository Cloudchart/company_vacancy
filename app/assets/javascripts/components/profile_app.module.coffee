# @cjsx React.DOM


ProfileInfo        = require('components/profile/info')
PinboardsComponent = require('components/pinboards/pinboards')


module.exports = React.createClass

  displayName: 'ProfileApp'

  propTypes:
    uuid:     React.PropTypes.string.isRequired
    readOnly: React.PropTypes.bool

  getDefaultProps: ->
    readOnly: false


  render: ->
    <section className="user-profile">
      <header>
        <ProfileInfo
          uuid     = { @props.uuid }
          readOnly = { @props.readOnly } />
      </header>
      <PinboardsComponent
        uuid = { @props.uuid } />
    </section>
