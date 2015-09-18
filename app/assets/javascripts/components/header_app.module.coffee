# @cjsx React.DOM

# Exports
#
module.exports = React.createClass


  displayName: 'HeaderApp'

  handleLoginButtonClick: (event) ->
    event.preventDefault()
    window.location = @props.login_url


  renderLogo: ->
    <a href={ @props.root_url } className="site-logo" />


  renderBetaIcon: (link) ->
    return null unless link.is_beta
    <i className="beta">&beta;</i>


  renderLinkIcon: (link) ->
    return null unless link.icon
    <i className={ link.icon } />


  renderLinkContent: (link) ->
    <span>
      { link.title }
      { @renderBetaIcon(link) }
    </span>


  renderLink: (link, i) ->
    <a href={ link.url } key={ i } className="through">
      { @renderLinkIcon(link) }
      { @renderLinkContent(link) }
    </a>

  renderLinks: ->
    return null unless @props.user.id

    <nav>
      { @props.links.map @renderLink }
    </nav>


  renderUser: ->
    if @props.user.id
      <nav className="user">
        <a href={ @props.user.url } className="through">{ @props.user.name }</a>
        <a href={ @props.logout_url }>
          <i className="fa fa-sign-in" />
        </a>
      </nav>
    else
      <button className="transparent" onClick={ @handleLoginButtonClick }>
        Login with Twitter
        <i className="fa fa-twitter" />
      </button>


  render: ->
    <div className="site-header">
      { @renderLogo() }

      { @renderLinks() }

      { @renderUser() }
    </div>
