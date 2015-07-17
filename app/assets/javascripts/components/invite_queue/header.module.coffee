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
          { @props.user.first_name },
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
        { "Well done, " }
        <strong>
          { @props.user.first_name },
        </strong>
        { " you've been added to our invite queue." }
      </p>

      <p>
        { "CloudChart is a brand new tool evolving every day, so it's open to a limited amount of founders for a while. We carefully review each founder's request, and will get in touch as soon as your invite is ready." }
      </p>
    </header>


  render: ->
    if @justCreated()
      @renderNewHeader()
    else
      @renderOldHeader()
