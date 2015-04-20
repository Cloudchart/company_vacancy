# @cjsx React.DOM

# Imports
#
cx = React.addons.classSet

CloudFlux       = require('cloud_flux')
GlobalState     = require('global_state/state')

CompanyStore    = require('stores/company')
PostStore       = require('stores/post_store')
StoryStore      = require('stores/story_store')

CompanyActions  = require('actions/company')

CompanyHeader   = require('components/company/header')
Timeline        = require('components/company/timeline')
BlockEditor     = require('components/editor/block_editor')
Settings        = require('components/company/settings')
AccessRights    = require('components/company/access_rights')
StandardButton  = require('components/form/buttons').StandardButton
CompanyNav      = require('components/company/main_nav')

# Main
#
Component = React.createClass

  # mixins: []
  # mixins: [GlobalState.mixin, CloudFlux.mixins.Actions]
  # propTypes: {}
  displayName: 'Company app'

  # getDefaultProps: ->
  #   cursor:
  #     stories: StoryStore.cursor.items

  getInitialState: ->
    # currentTab = @getCurrentTabName()
    currentTab = 'timeline'

    # _.extend @getStateFromStores(),
    # cursor:
    #   flags:               GlobalState.cursor(['stores', 'companies', 'flags', @props.uuid])
    #   meta:                GlobalState.cursor(['stores', 'companies', 'meta', @props.uuid])
    canEdit: !GlobalState.cursor(['stores', 'companies', 'flags', @props.uuid]).get('is_read_only')
    currentTab:            currentTab
    isEditingAbout:        false
    isEditingSettings:     currentTab == "settings"
    isAccessRightsLoading: false
    postsLoaded:           false
    story_id:              null

  # refreshStateFromStores: ->
  #   @setState(@getStateFromStores())
  
  # getStateFromStores: ->
  #   company:   CompanyStore.get(@props.uuid)
  #   posts:     PostStore.all()

  # onGlobalStateChange: ->
  #   @setState
  #     refreshed_at: + new Date
  #     story_id: @getCurrentStoryId()


  # Helpers
  # 
  isLoaded: ->
    !_.isUndefined(@state.cursor.flags.get('is_read_only')) && @state.company && @state.postsLoaded

  getMenuOptionClassName: (option) ->
    cx(active: @state.currentTab == option)

  canEdit: ->
    # @state.cursor.flags.get('is_read_only')
    @state.canEdit
    # !!GlobalState.cursor(['stores', 'companies', 'flags', @props.uuid])
    # isReadOnly = @state.cursor.flags.get('is_read_only')

    # !_.isUndefined(isReadOnly) && !isReadOnly

  # getVisibleTabs: ->
  #    Immutable.OrderedMap(
  #     timeline:  !Timeline.isEmpty() || @canEdit()
  #     about:     true
  #     users:     @canEdit()
  #     settings:  @canEdit()
  #   ).filter (visible) -> visible
  #    .keySeq()

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

  # getCurrentTabName: ->
  #   tabName = location.hash.substr(1) || null
  #   return 'timeline' if tabName.match(/story/)
  #   tabName

  getCurrentStoryId: ->
    if location.hash.match(/story/)
      story = @props.cursor.stories.find (story) -> story.get('formatted_name') is location.hash.split(/#story-/).pop()
      story.get('uuid')
    else
      null


  # Handlers
  # 
  # handleHashChange: ->
  #   currentTab = @getCurrentTabName()

  #   if @getVisibleTabs().contains(currentTab)
  #     if currentTab == 'users' && !@isAccessRightsLoaded()
  #       @fetchAccessRights()
  #     @setState
  #       currentTab:        currentTab
  #       isEditingSettings: currentTab == 'settings' 

  handleAboutViewModeChange: (value) ->
    @setState(isEditingAbout: value == 'edit')

  handleAccessRightsDone: -> 
    setTimeout =>
      @setState(isAccessRightsLoading: false)

  handlePostsLoaded: ->
    @setState postsLoaded: true

  handleStoryClick: (story) ->
    if @state.story_id != story.get('uuid')
      location.hash = "story-#{story.get('formatted_name')}"
      @setState(story_id: story.get('uuid'))

  handleNavChange: (currentTab) ->
    console.log 'handleNavChange', currentTab


  # Lifecylce Methods
  # 
  # componentDidMount: ->
    # CompanyStore.on('change', @refreshStateFromStores)
    # PostStore.on('change', @handlePostsLoaded)
    # window.addEventListener 'hashchange', @handleHashChange

    # @updateInitialTab()

  # componentDidUpdate: ->
    # @updateInitialTab()

  # componentWillUnmount: ->
    # CompanyStore.off('change', @refreshStateFromStores)
    # PostStore.off('change', @handlePostsLoaded)
    # window.removeEventListener 'hashchange', @handleHashChange


  # Renderers
  #
  # renderTabs: ->
  #   @getVisibleTabs().map (tabName) =>
  #     <li key = { tabName } className = { @getMenuOptionClassName(tabName) } >
  #       <a href = { location.pathname + "#" + tabName } className="for-group">
  #         { tabName }
  #       </a>
  #     </li>
  #   .toArray()

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

  # renderMenu: ->
  #   <nav className="tabs">
  #     <ul>
  #       { @renderTabs() }
  #     </ul>
  #   </nav>

  renderContent: ->
    switch @state.currentTab
      when 'timeline'
        <Timeline 
          company_id = { @props.uuid }
          story_id = { @state.story_id }
          onStoryClick = { @handleStoryClick }
          readOnly = { !@canEdit() } />
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
    # console.log 'render'
    # return null unless @state.company and @props.cursor.stories.deref(false)

    <div className="wrapper">
      <CompanyHeader
        uuid = { @props.uuid }
        readOnly = { !@state.isEditingSettings }
      />

      <CompanyNav onChange = { @handleNavChange } canEdit = { @state.canEdit } />

      <section className="content">
        { @renderContent() }
      </section>
    </div>


# Exports
#
module.exports = Component
