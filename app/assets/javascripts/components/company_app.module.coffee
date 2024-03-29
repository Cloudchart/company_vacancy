# @cjsx React.DOM

# Imports
#
cx = React.addons.classSet

GlobalState     = require('global_state/state')

CompanyStore    = require('stores/company')
PostStore       = require('stores/post_store')

CompanyHeader   = require('components/company/header')
Timeline        = require('components/company/timeline')
BlockEditor     = require('components/editor/block_editor')
Settings        = require('components/company/settings')
AccessRights    = require('components/company/access_rights')
StandardButton  = require('components/form/buttons').StandardButton
CompanyTabs     = require('components/company/tabs')

# Main
#
Component = React.createClass

  # propTypes: {}
  displayName: 'CompanyApp'
  mixins: [GlobalState.mixin]

  getDefaultProps: ->
    cursor:
      companies_flags: GlobalState.cursor(['stores', 'companies', 'flags'])

  getInitialState: ->
    canEdit: null
    currentTab: null
    isEditingAbout: false
    isCompanyLoaded: false
    postsLoaded: false

  onGlobalStateChange: ->
    @setState canEdit: !@props.cursor.companies_flags.cursor(@props.uuid).get('is_read_only')


  # Helpers
  # 
  isLoaded: ->
    @state.canEdit isnt null and @state.isCompanyLoaded and @state.postsLoaded


  # Handlers
  # 
  handleAboutViewModeChange: (value) ->
    @setState(isEditingAbout: value == 'edit')

  handleNavChange: (currentTab) ->
    @setState currentTab: currentTab

  handleCompanyLoaded: ->
    @setState isCompanyLoaded: true

  handlePostsLoaded: ->
    @setState postsLoaded: true


  # Lifecylce Methods
  # 
  componentDidMount: ->
    CompanyStore.on('change', @handleCompanyLoaded)
    PostStore.on('change', @handlePostsLoaded)

  componentWillUnmount: ->
    CompanyStore.off('change', @handleCompanyLoaded)
    PostStore.off('change', @handlePostsLoaded)


  # Renderers
  #
  renderEditControl: ->
    return null unless @state.canEdit

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


  renderContent: ->
    switch @state.currentTab
      when 'timeline'
        <Timeline 
          company_id = { @props.uuid }
          readOnly = { !@state.canEdit } />
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
        <AccessRights uuid = { @props.uuid } />
      when 'settings'
        <Settings uuid = { @props.uuid } />
      else
        null


  render: ->
    return null unless @isLoaded()

    <div className="wrapper">
      <CompanyHeader
        uuid = { @props.uuid }
        readOnly = { @state.currentTab isnt 'settings' }
      />

      <CompanyTabs 
        onChange = { @handleNavChange }
        canEdit = { @state.canEdit }
      />

      <section className="content">
        { @renderContent() }
      </section>
    </div>


# Exports
#
module.exports = Component
