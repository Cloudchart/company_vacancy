# @cjsx React.DOM


# Components
#
UserPinboards  = require('components/pinboards/lists/user')


# Exports
#
module.exports = React.createClass

  displayName: 'PinboardsApp'

  propTypes:
    user_id: React.PropTypes.string.isRequired

  render: ->
    <section className="pinboards-wrapper">
      <header className="cloud-columns cloud-columns-flex">Your collections</header>
      <UserPinboards user_id = { @props.user_id } showPrivate = { true } />
    </section>