# @cjsx React.DOM

# Imports
#
tag = React.DOM
cx = React.addons.classSet

CloudFlux       = require('cloud_flux')
GlobalState     = require('global_state/state')

CompanyStore    = require('stores/company')
PostStore       = require('stores/post_store')

CompanyActions  = require('actions/company')

CompanyHeader   = require('components/company/header')
Timeline        = require('components/company/timeline')
BlockEditor     = require('components/editor/block_editor')
Settings        = require('components/company/settings')
AccessRights    = require('components/company/access_rights')
StandardButton  = require('components/form/buttons').StandardButton

# Main
#
Component = React.createClass

  mixins: [GlobalState.mixin, CloudFlux.mixins.Actions]
  # propTypes: {}
  displayName: 'Company app'

  getDefaultProps: ->
    cursor: GlobalState.cursor(['meta', 'company'])

  getInitialState: ->
    currentTab = location.hash.substr(1) || null

    _.extend @getStateFromStores(),
      cursor:
        meta:                GlobalState.cursor(['stores', 'companies', 'meta', @props.uuid])
        flags:               GlobalState.cursor(['stores', 'companies', 'flags', @props.uuid])
      currentTab:            currentTab
      isEditingAbout:        false
      isEditingSettings:     currentTab == "settings"
      isAccessRightsLoading: false
      postsLoaded:           false

  refreshStateFromStores: ->
    @setState(@getStateFromStores())
  
  getStateFromStores: ->
    company:   CompanyStore.get(@props.uuid)
    posts:     PostStore.all()


  # Helpers
  # 
  isLoaded: ->
    !_.isUndefined(@state.cursor.flags.get('is_read_only')) && @state.company && @state.postsLoaded

  getMenuOptionClassName: (option) ->
    cx(active: @state.currentTab == option)

  canEdit: ->
    isReadOnly = @state.cursor.flags.get('is_read_only')

    !_.isUndefined(isReadOnly) && !isReadOnly

  getVisibleTabs: ->
     Immutable.OrderedMap(
      timeline:  !Timeline.isEmpty() || @canEdit()
      about:     true
      users:     @canEdit()
      settings:  @canEdit()
    ).filter (visible) -> visible
     .keySeq()

  getInitialTab: ->
    visibleTabs = @getVisibleTabs()

    if !@state.currentTab || !visibleTabs.contains(@state.currentTab)
      visibleTabs.first()
    else
      @state.currentTab

  updateInitialTab: ->
    return null unless @isLoaded()

    if (tab = @getInitialTab()) != @state.currentTab
      @setState
        currentTab:        tab
        isEditingSettings: tab == 'settings'
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
      @setState
        currentTab:        currentTab
        isEditingSettings: currentTab == 'settings' 

  handleAboutViewModeChange: (value) ->
    @setState(isEditingAbout: value == 'edit')

  handleAccessRightsDone: -> 
    setTimeout =>
      @setState(isAccessRightsLoading: false)

  handlePostsLoaded: ->
    @setState postsLoaded: true


  # Lifecylce Methods
  # 
  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)
    PostStore.on('change', @handlePostsLoaded)
    window.addEventListener 'hashchange', @handleHashChange

    @updateInitialTab()

  componentDidUpdate: ->
    @updateInitialTab()

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)
    PostStore.off('change', @handlePostsLoaded)

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
    return null unless @isAccessRightsLoaded()
    
    <AccessRights uuid={@props.uuid} />

  renderEditControl: ->
    return null unless @canEdit()

    if @state.isEditingAbout
      <StandardButton 
        className = "transparent"
        iconClass = "cc-icon cc-times"
        onClick   = { => @handleAboutViewModeChange("view") } />
    else
      <StandardButton 
        className = "edit-mode transparent"
        onClick   = { => @handleAboutViewModeChange("edit") }
        text      = "edit" />

  renderOkButton: ->
    return null unless @state.isEditingAbout

    <StandardButton 
      className = "cc"
      onClick   = { => @handleAboutViewModeChange("view") }
      text      = "OK" />

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
          readOnly   = { !@canEdit() } />
      when 'about'
        <section className="about">
          <BlockEditor
            company_id          = { @props.uuid }
            owner_id            = { @props.uuid }
            owner_type          = "Company"
            editorIdentityTypes = { ['Person', 'Picture', 'Paragraph'] }
            classForArticle     = "editor company company-2_0"
            readOnly            = { !@state.isEditingAbout } />
          { @renderEditControl() }
          { @renderOkButton() }
        </section>
      when 'users'
        @renderAccessRights()
      when 'settings'
        <Settings uuid = { @props.uuid } />


  render: ->
    return null unless @state.company

    <div className="wrapper">
      <CompanyHeader
        uuid                  = { @props.uuid }
        readOnly              = { !@state.isEditingSettings }
      />
      { @renderMenu() }
      <section className="content">
        { @renderContent() }
      </section>
    </div>

# Exports
#
module.exports = Component
