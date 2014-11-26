# @cjsx React.DOM

# Imports
#
tag = React.DOM

CompanyStore    = require('stores/company')
BlockStore      = require('stores/block_store')

Blockable       = require('components/mixins/blockable')
SortableList    = require('components/shared/sortable_list')
CompanyHeader   = require('components/company/header')
Timeline        = require('components/company/timeline')

# Main
#
Component = React.createClass

  mixins: [Blockable]

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
    @setState({ readOnly: data.readOnly })

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

    blocks: BlockStore.filter (block) => block.owner_type == 'Company' and block.owner_id == @props.id
    company: company
    readOnly: if company then company.flags.is_read_only else true
  
  getInitialState: ->
    state            = @getStateFromStores()
    state.position   = null
    state.owner_type = 'Company'
    state

  render: ->
    if @state.company
      blocks = _.map @gatherBlocks(), (block, i) =>
        [
          @getSectionPlaceholder(i)
          block
        ]

      <div className="wrapper">
        <CompanyHeader
          id = {@props.id}
          readOnly = {@state.readOnly}
          shouldDisplayViewMode = {if @state.company.flags.is_read_only then false else true}
          onChange = {@handleViewModeChange}
        />
        
        <SortableList
          component={tag.article}
          className="editor company company-2_0"
          onOrderChange={@handleSortableChange}
          onOrderUpdate={@handleSortableUpdate}
          readOnly={@state.readOnly}
          dragLockX
        >
          {blocks}
          {@getSectionPlaceholder(blocks.length)}
        </SortableList>

        <Timeline company_id={@state.company.uuid}, readOnly={@state.readOnly} />
      </div>

    else
      null

# Exports
#
module.exports = Component
