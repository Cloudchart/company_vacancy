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

  renderLinkIcon: (link) ->
    return null unless link.icon

    <i className={ link.icon } />

  renderLink: (link) ->
    if link.url
      <a href={ link.url }>
        { @renderLinkIcon(link) }
        <span>{ link.title }</span>
      </a>
    else
      <span>
        { @renderLinkIcon(link) }
        <span>{ link.title }</span>
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
      login:    <a href={ @props.login_url }>Login</a>


  render: ->
    <div className="header-content">
      { @renderLogo() }

      { @renderLinks() }

      <nav>
        { @renderUser() }
      </nav>
    </div>
