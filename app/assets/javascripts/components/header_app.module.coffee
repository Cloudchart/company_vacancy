# @cjsx React.DOM

# Exports
#
module.exports = React.createClass


  displayName: 'HeaderApp'


  renderLogo: ->
    <div className="local-menu">
      <a href={ @props.root_url } className="logo" />
      <a href={ @props.root_url } className="title" dangerouslySetInnerHTML={ __html: @props.title } />
    </div>

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

  renderLink: (link) ->
    if link.url
      <a href={ link.url }>
        { @renderLinkIcon(link) }
        { @renderLinkContent(link) }
      </a>
    else
      <span>
        { @renderLinkIcon(link) }
        { @renderLinkContent(link) }
      </span>

  renderLinks: ->
    links = Immutable.Seq(@props.links).map (link, index) =>
      <li key={ index }>
        { @renderLink(link) }
      </li>

    <ul className="main-menu">
      { links.toArray() }
    </ul>


  renderUser: ->
    if @props.user.id
      profile:  <a href={ @props.user.url } className="profile auth">{ @props.user.name }</a>
      logout:   <a href={ @props.logout_url } className="sign-out header square auth"><i className="fa fa-sign-out" /></a>
    else
      login:    <a href={ @props.login_url }>Log in with Twitter</a>


  render: ->
    <div className="header-content">
      { @renderLogo() }

      { @renderLinks() }

      <nav>
        { @renderUser() }
      </nav>
    </div>
