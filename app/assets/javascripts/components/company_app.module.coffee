# @cjsx React.DOM

# Imports
#
tag = React.DOM
cx = React.addons.classSet

CompanyStore    = require('stores/company')
BlockStore      = require('stores/block_store')

Blockable       = require('components/mixins/blockable')
GlobalState     = require('global_state/state')
SortableList    = require('components/shared/sortable_list')
CompanyHeader   = require('components/company/header')
Timeline        = require('components/company/timeline')

# Main
#
Component = React.createClass

  mixins: [Blockable, GlobalState.mixin]

  # Helpers
  # 
  identityTypes: ->
    People:     'Person'
    Vacancies:  'Vacancy'
    Picture:    'Picture'
    Paragraph:  'Paragraph'


  # Handlers
  # 
  handleViewModeChange: (data) ->
    @props.cursor.set('mode', if data.readOnly then 'view' else 'edit')


  # Lifecylce Methods
  #   
  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)
    BlockStore.on('change', @refreshStateFromStores)

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)
    BlockStore.off('change', @refreshStateFromStores)

  # Component Specifications
  # 
  refreshStateFromStores: ->
    @setState(@getStateFromStores())

  getStateFromStores: ->
    company = CompanyStore.get(@props.id)

    blocks:   BlockStore.filter (block) => block.owner_type == 'Company' and block.owner_id == @props.id
    company:  company
    #readOnly: if company then company.flags.get('is_read_only') else true
  
  
  onGlobalStateChange: ->
    @setState
      readOnly: @props.cursor.get('mode', 'edit') isnt 'edit'
  

  getDefaultProps: ->
    cursor: GlobalState.cursor(['meta', 'company'])
  

  getInitialState: ->
    state             = @getStateFromStores()
    state.position    = null
    state.owner_type  = 'Company'
    state.cursor      =
      meta:   GlobalState.cursor(['stores', 'companies', 'meta', @props.id])
      flags:  GlobalState.cursor(['stores', 'companies', 'flags', @props.id])
    state

  render: ->
    return null unless @state.company
    
    isReadOnly = @state.cursor.flags.get('is_read_only')

    classes = cx
      'editor company company-2_0': true
      'draggable': !isReadOnly

    blocks = _.map @gatherBlocks(), (block, i) =>
      [
        @getSectionPlaceholder(i)
        block
      ]

    <div className="wrapper">
      <CompanyHeader
        id = {@props.id}
        readOnly = {@state.readOnly}
        shouldDisplayViewMode = {!isReadOnly}
        onChange = {@handleViewModeChange}
      />
      
      <SortableList
        component = {tag.article}
        className = {classes}
        onOrderChange = {@handleSortableChange}
        onOrderUpdate = {@handleSortableUpdate}
        readOnly = {isReadOnly}
        dragLockX
      >
        {blocks}
        {@getSectionPlaceholder(blocks.length)}
      </SortableList>

      <Timeline company_id={@state.company.uuid} readOnly={isReadOnly} />
    </div>

# Exports
#
module.exports = Component
