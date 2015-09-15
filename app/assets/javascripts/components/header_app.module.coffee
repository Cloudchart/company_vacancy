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
    <nav>
      { @props.links.map @renderLink }
    </nav>
    # links = Immutable.Seq(@props.links).map (link, index) =>
    #   <li key={ index }>
    #     { @renderLink(link) }
    #   </li>
    #
    # <ul className="main-menu">
    #   { links.toArray() }
    # </ul>


  renderUser: ->
    <nav className="user">
      <a href={ @props.user.url } className="through">{ @props.user.name }</a>
      <a href={ @props.logout_url }>
        <i className="fa fa-sign-in" />
      </a>
    </nav>
    # <button className="transparent" onClick={ @handleLoginButtonClick }>
    #   Login with Twitter
    #   <i className="fa fa-twitter" />
    # </button>

    # if @props.user.id
    #   profile:  <a href={ @props.user.url } className="profile auth">{ @props.user.name }</a>
    #   logout:   <a href={ @props.logout_url } className="sign-out header square auth"><i className="fa fa-sign-out" /></a>
    # else
    #   login:    <a href={ @props.login_url }>Log in with Twitter</a>


  render: ->
    console.log @props
    <div className="site-header">
      { @renderLogo() }

      { @renderLinks() }

      { @renderUser() }
    </div>
