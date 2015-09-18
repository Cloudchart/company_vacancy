# @cjsx React.DOM

device = require('utils/device')


# Exports
#
module.exports = React.createClass


  displayName: 'HeaderApp'


  getInitialState: ->
    is_menu_shown: false


  handleLoginButtonClick: (event) ->
    event.preventDefault()
    window.location = @props.login_url


  handleBarsClick: (event) ->
    event.preventDefault()
    @setState({
      is_menu_shown: !@state.is_menu_shown
    })


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
    return null if device.is_iphone
    return null unless @props.user.id

    <nav>
      { @props.links.map @renderLink }
    </nav>


  renderUser: ->
    if @props.user.id
      return null if device.is_iphone
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


  renderSandwitch: ->
    return null unless @props.user.id
    return null unless device.is_iphone

    <a href="" className="through" style={ fontSize: 60 } onClick={ @handleBarsClick }>
      <i className="fa fa-bars" />
    </a>


  renderMobileMenu: ->
    return null unless @state.is_menu_shown

    links = @props.links.map (link, i) =>
      <li key={ i }>
        <a className="through" href={ link.url }>
          { link.title }
        </a>
      </li>

    <ul className="header-mobile-menu">
      { links }
      <li className="spacer" />
      <li className="logout">
        Logout
        <a href={ @props.logout_url }>
          <i className="fa fa-sign-in" />
        </a>
      </li>
    </ul>


  render: ->
    console.log @props
    <div className="site-header">
      { @renderLogo() }

      { @renderLinks() }

      { @renderUser() }
      { @renderSandwitch() }
      { @renderMobileMenu() }
    </div>
