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

  # Component Specifications
  # 
  getStateFromStores: ->
    company = CompanyStore.get(@props.id)

    blocks: BlockStore.filter (block) => block.owner_type == 'Company' and block.owner_id == @props.id
    company: company
    readOnly: if company then company.flags.is_read_only else true

  refreshStateFromStores: ->
    @setState(@getStateFromStores())
  
  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)
    BlockStore.on('change', @refreshStateFromStores)

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)
    BlockStore.off('change', @refreshStateFromStores)
  
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
          key             = {@props.id}
          name            = {@state.company.name}
          description     = {@state.company.description}
          logotype_url    = {@state.company.logotype_url}
          readOnly        = {@state.readOnly}
          can_follow      = {@state.company.flags.can_follow}
          is_followed     = {@state.company.flags.is_followed}
          invitable_roles = {@state.company.meta.invitable_roles}
          onChange        = {@handleViewModeChange}
          shouldDisplayViewMode = {if @state.company.flags.is_read_only then false else true}
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
