# @cjsx React.DOM

# Imports
#
tag = React.DOM
cx = React.addons.classSet

CloudFlux       = require('cloud_flux')
GlobalState     = require('global_state/state')

CompanyStore    = require('stores/company')

CompanyActions  = require('actions/company')

CompanyHeader   = require('components/company/header')
Timeline        = require('components/company/timeline')
BlockEditor     = require('components/editor/block_editor')
Settings        = require('components/company/settings')
AccessRights    = require('components/company/access_rights')

# Main
#
Component = React.createClass

  mixins: [GlobalState.mixin, CloudFlux.mixins.Actions]
  # propTypes: {}
  displayName: 'Company app'

  getDefaultProps: ->
    cursor: GlobalState.cursor(['meta', 'company'])

  getInitialState: ->
    state             = @getStateFromStores()
    state.cursor      =
      meta:   GlobalState.cursor(['stores', 'companies', 'meta', @props.uuid])
      flags:  GlobalState.cursor(['stores', 'companies', 'flags', @props.uuid])
    state.currentTab = location.hash.substr(1) || null
    state.isAccessRightsLoading = false
    state

  refreshStateFromStores: ->
    @setState(@getStateFromStores())
  
  getStateFromStores: ->
    company:     CompanyStore.get(@props.uuid)
  
  onGlobalStateChange: ->
    @setState
      readOnly:    @props.cursor.get('mode', 'edit') isnt 'edit'


  # Helpers
  # 
  getMenuOptionClassName: (option) ->
    cx(active: @state.currentTab == option)

  canEdit: ->
    isReadOnly = @state.cursor.flags.get('is_read_only')

    !_.isUndefined(isReadOnly) && !isReadOnly

  isInViewMode: ->
    @state.readOnly || !@canEdit()

  getVisibleTabs: ->
    visibleTabs = Immutable.Seq(['timeline', 'about'])
    visibleTabs = visibleTabs.concat(['users', 'settings']) if @canEdit()
    visibleTabs

  getInitialTab: ->
    visibleTabs = @getVisibleTabs()

    if !@state.currentTab || !visibleTabs.contains(@state.currentTab)
      visibleTabs.first()
    else
      @state.currentTab

  updateInitialTab: ->
    if !_.isUndefined(@state.cursor.flags.get('is_read_only'))
      if (tab = @getInitialTab()) != @state.currentTab
        location.hash = tab
      else if @state.currentTab == 'users'
        @fetchAccessRights()

  isAccessRightsLoaded: ->
    GlobalState.cursor(['flags', 'companies']).get('isAccessRightsLoaded')

  getCloudFluxActions: ->
    'company:access_rights:fetch:done': @handleAccessRightsDone

  fetchAccessRights: ->
    if !@isAccessRightsLoaded() && !@state.isAccessRightsLoading
      @setState(isAccessRightsLoading: true)
      CompanyActions.fetchAccessRights(@props.uuid)


  # Handlers
  # 
  handleHashChange: ->
    currentTab = location.hash.substr(1)

    if @getVisibleTabs().contains(currentTab)
      if currentTab == 'users' && !@isAccessRightsLoaded()
        @fetchAccessRights()
      @setState currentTab: currentTab

  handleViewModeChange: (data) ->
    @props.cursor.set('mode', if data.readOnly then 'view' else 'edit')

  handleAccessRightsDone: -> 
    setTimeout =>
      @setState(isAccessRightsLoading: false)


  # Lifecylce Methods
  # 
  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)
    window.addEventListener 'hashchange', @handleHashChange

    @updateInitialTab()

  componentDidUpdate: ->
    @updateInitialTab()

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)

    window.removeEventListener 'hashchange', @handleHashChange


  # Renderers
  #
  renderTabs: ->
    @getVisibleTabs().map (tabName) =>
      <li key = { tabName } className = { @getMenuOptionClassName(tabName) } >
        <a href = { location.pathname + "#" + tabName } className="for-group">
          { tabName }
        </a>
      </li>
    .toArray()

  renderAccessRights: ->
    if @isAccessRightsLoaded()
      <AccessRights uuid={@props.uuid} />
    else
      <div />  

  renderMenu: ->
    <nav className="tabs">
      <ul>
        { @renderTabs() }
      </ul>
    </nav>

  renderContent: ->
    switch @state.currentTab
      when 'timeline'
        <Timeline 
          company_id = { @state.company.uuid }
          readOnly   = { @isInViewMode() } />
      when 'about'
        <BlockEditor
          company_id          = { @props.uuid }
          owner_id            = { @props.uuid }
          owner_type          = "Company"
          editorIdentityTypes = { ['Person', 'Picture', 'Paragraph'] }
          classForArticle     = "editor company company-2_0"
          readOnly            = { @isInViewMode() } />
      when 'users'
        @renderAccessRights()
      when 'settings'
        <Settings uuid = { @props.uuid } />


  render: ->
    return null unless @state.company

    <div className="wrapper">
      <CompanyHeader
        uuid                  = { @props.uuid }
        readOnly              = { @isInViewMode() }
        shouldDisplayViewMode = { !@state.cursor.flags.get('is_read_only') }
        onChange              = { @handleViewModeChange }
      />
      { @renderMenu() }
      <section className="content">
        { @renderContent() }
      </section>
    </div>

# Exports
#
module.exports = Component
