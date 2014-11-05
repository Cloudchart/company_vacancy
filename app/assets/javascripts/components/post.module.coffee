# @cjsx React.DOM

# Imports
# 
tag = React.DOM

Blockable = require('components/mixins/blockable')

CompanyStore = require('stores/company')
PostStore = require('stores/post_store')
BlockStore = require('stores/block_store')

PostActions = require('actions/post_actions')
BlockableActions = require('actions/mixins/blockable_actions')

SortableList = require('components/shared/sortable_list')

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
  # gatherSomething: ->

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
    state.owner_type = 'Post'
    state

  render: ->
    if @state.post
      blocks = _.map @gatherBlocks(), (block, i) =>
        [
          @getSectionPlaceholder(i)
          block
        ]

      <SortableList
        component={tag.article}
        className="editor post"
        onOrderChange={@handleSortableChange}
        onOrderUpdate={@handleSortableUpdate}
        readOnly={@state.company.flags.is_read_only}
        dragLockX
      >
        {blocks}
        {@getSectionPlaceholder(blocks.length)}
      </SortableList>

    else
      null

# Exports
# 
module.exports = Component
