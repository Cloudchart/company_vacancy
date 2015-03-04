# @cjsx React.DOM


ProfileInfo        = require('components/profile/info')
PinboardsComponent = require('components/pinboards/pinboards')
CompaniesList      = require('components/company/list')

cs = React.addons.classSet

module.exports = React.createClass

  displayName: 'ProfileApp'

  propTypes:
    uuid:     React.PropTypes.string.isRequired

  getInitialState: ->
    selected: location.hash.substr(1) || 'pins' || ''


  # Helpers
  #
  getMenuOptionClassName: (option) ->
    cx(active: @state.selected == option)


  # Handlers
  #
  handleMenuClick: (selected) ->
    @setState selected: selected
    location.hash = selected


  # Renderers
  #
  renderMenu: ->
    <nav>
      <ul>
        <li className = { @getMenuOptionClassName('pins') } onClick = { @handleMenuClick.bind(@, 'pins') } >Pins</li>
        <li className = { @getMenuOptionClassName('companies') } onClick = { @handleMenuClick.bind(@, 'companies') } >Companies</li>
      </ul>
    </nav>

  renderContent: ->
    if @state.selected == "pins"
      <PinboardsComponent uuid = { @props.uuid } />
    else if @state.selected = "companies"
      <CompaniesList uuid = { @props.uuid } />


  render: ->
    <section className="user-profile">
      <header>
        <ProfileInfo
          uuid     = { @props.uuid } />
        { @renderMenu() } 
      </header>
      { @renderContent() }
    </section>
