# @cjsx React.DOM


# Components
#
HeaderComponent = require('components/invite_queue/header')
AvatarComponent = require('components/avatar')


# Exports
#
module.exports = React.createClass


  renderName: ->
    return null unless @props.user.full_name

    <p className="name">{ @props.user.full_name }</p>


  renderOccupation: ->
    occupation = Immutable.Seq([@props.user.occupation, @props.user.company])
      .filter (part) -> !!part
      .join(' at ')

    return null unless occupation

    <p className="occupation">{ occupation }</p>


  renderEmail: ->
    return null unless @props.user.email

    <p className="email">{ @props.user.email }</p>


  renderInfo: ->
    <div className="info">
      <AvatarComponent value={ @props.user.full_name } avatarURL={ @props.user.avatar_url } />
      { @renderName() }
      { @renderOccupation() }
      { @renderEmail() }
    </div>


  renderButton: ->
    <button className="cc" onClick={ @props.onClick }>
      Update
    </button>


  render: ->
    <section className="invite-queue view">
      <HeaderComponent user = { @props.user } />
      { @renderInfo() }
      { @renderButton() }
    </section>
