# @cjsx React.DOM


# Components
#
AvatarComponent = require('components/avatar')


# Exports
#
module.exports = React.createClass


  justCreated: ->
    @props.user.created_at is @props.user.updated_at


  renderNewHeader: ->
    <header>
      <aside>
        <AvatarComponent value={ @props.user.full_name } avatarURL={ @props.user.avatar_url } />
      </aside>

      <p>
        <strong>
          { "Hello," }
          <br />
          { @props.user.full_name },
        </strong>
        { " and welcome to the CloudChart invite queue." }
        <br />
        { "Yes, we're popular." }
      </p>

      <p>
        { "If you, like us, rather act than wait, tell us a bit more about yourself. The more we know, the faster we wrap and send you that invite " }
        <i className="fa fa-send" />
      </p>
    </header>


  renderOldHeader: ->
    <header>
      <p>
        <strong>
          { @props.user.full_name },
        </strong>
        <br />
        { "you're in CloudChart invite queue. Thank you for providing additional information, we'll contact you when your invite is ready." }
      </p>

      <p>
        { "Feel free to check this page to see if you've got invite already." }
      </p>
    </header>


  render: ->
    if @justCreated()
      @renderNewHeader()
    else
      @renderOldHeader()
