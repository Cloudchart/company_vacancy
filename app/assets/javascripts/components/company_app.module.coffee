# @cjsx React.DOM

# Imports
#
tag = React.DOM
cx = React.addons.classSet

GlobalState     = require('global_state/state')

CompanyStore    = require('stores/company')

CompanyHeader   = require('components/company/header')
Timeline        = require('components/company/timeline')
BlockEditor     = require('components/editor/block_editor')

# Main
#
Component = React.createClass

  mixins: [GlobalState.mixin]

  # Helpers
  # 
  # gatherSomething: ->


  # Handlers
  # 
  handleViewModeChange: (data) ->
    @props.cursor.set('mode', if data.readOnly then 'view' else 'edit')


  # Lifecylce Methods
  #   
  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)


  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)


  # Component Specifications
  # 
  refreshStateFromStores: ->
    @setState(@getStateFromStores())

  
  getStateFromStores: ->
    company: CompanyStore.get(@props.uuid)
  
  
  onGlobalStateChange: ->
    @setState
      readOnly: @props.cursor.get('mode', 'edit') isnt 'edit'
  

  getDefaultProps: ->
    # company meta data created at the client side (not connected with stores)
    cursor: GlobalState.cursor(['meta', 'company'])
  

  getInitialState: ->
    state             = @getStateFromStores()
    state.cursor      =
      meta:   GlobalState.cursor(['stores', 'companies', 'meta', @props.uuid])
      flags:  GlobalState.cursor(['stores', 'companies', 'flags', @props.uuid])
    state

  render: ->
    return null unless @state.company
    isReadOnly = @state.cursor.flags.get('is_read_only')

    <div className="wrapper">
      <CompanyHeader
        id = {@props.uuid}
        readOnly = {isReadOnly}
        shouldDisplayViewMode = {!isReadOnly}
        onChange = {@handleViewModeChange}
      />

      <BlockEditor
        company_id = {@props.uuid}
        owner_id = {@props.uuid}
        owner_type = "Company"
        editorIdentityTypes = {['Person', 'Vacancy', 'Picture', 'Paragraph']}
        classForArticle = "editor company company-2_0"
        readOnly = {isReadOnly}
      />

      <Timeline 
        company_id = {@state.company.uuid}
        readOnly = {isReadOnly} 
      />
    </div>

# Exports
#
module.exports = Component
