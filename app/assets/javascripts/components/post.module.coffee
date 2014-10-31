# @cjsx React.DOM

# Imports
# 
tag = React.DOM

Blockable = require('components/mixins/blockable')

CompanyStore = require('stores/company')
PostStore = require('stores/post_store')
BlockStore = require('stores/block_store')

BlockActions = require('actions/block_actions')
PostActions = require('actions/post_actions')

SortableList = require('components/shared/sortable_list')
SortableListItem  = require('components/shared/sortable_list_item')

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
  handleChooseBlockTypeClick: (type) ->
    _.chain(@state.blocks)
      .filter (block) => block.position >= @state.position
      .each (block) => BlockStore.update(block.uuid, { position: block.position + 1 })

    key = BlockStore.create({ owner_id: @props.id, owner_type: 'Post', identity_type: type, position: @state.position })

    PostActions.createBlock(key, BlockStore.get(key).toJSON())

    @setState({ position: null })

  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores())

  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->

  # Component Specifications
  # 
  # getDefaultProps: ->

  getStateFromStores: ->
    company: CompanyStore.get(@props.company_id)
    post: PostStore.get(@props.id)
    blocks: BlockStore.filter (block) => block.owner_type == 'Post' and block.owner_id == @props.id

  getInitialState: ->
    state = @getStateFromStores()
    state.position = null
    state

  render: ->

    <SortableList
      component={tag.article}
      className="editor post"
      onOrderChange={@handleSortableChange}
      onOrderUpdate={@handleSortableUpdate}
      readOnly={@props.readOnly}
      dragLockX
    >
      {@SectionPlaceholderComponent(0)}
    </SortableList>

# Exports
# 
module.exports = Component
