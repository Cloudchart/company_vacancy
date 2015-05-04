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


  renderLinks: ->
    links = Immutable.Seq(@props.links).map (link, index) ->
      linkOrTitle = if link.url
        <a href={ link.url }>{ link.title }</a>
      else
        link.title

      <li key={ index }>
        { linkOrTitle }
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
