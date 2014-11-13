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
ModalActions = require('actions/modal_actions')

SortableList = require('components/shared/sortable_list')
# PostForm = require('components/form/post_form')
AutoSizingInput = require('components/form/autosizing_input')

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
  handleFieldChange: ->
  handleFieldBlur: ->
  handleFieldKeyup: ->

  # handleEditClick: (event) ->    
  #   event.preventDefault()

  #   ModalActions.show(PostForm({
  #     attributes: @state.post.toJSON()
  #     onSubmit:   @handlePostFormSubmit
  #   }))

  # handlePostFormSubmit: (attributes) ->
  #   PostActions.update(@state.post.uuid, attributes.toJSON())
  #   ModalActions.hide()

  handleDestroyClick: (event) ->
    event.preventDefault()
    PostActions.destroy(@state.post.uuid) if confirm('Are you sure?')

  # Lifecycle Methods
  # 
  # componentWillMount: ->
  componentDidMount: ->
    # PostStore.on('change', @refreshStateFromStores)
    BlockStore.on('change', @refreshStateFromStores)

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores())

  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  componentWillUnmount: ->
    # PostStore.off('change', @refreshStateFromStores)
    BlockStore.off('change', @refreshStateFromStores)

  # Component Specifications
  # 
  refreshStateFromStores: ->
    @setState(@getStateFromStores())

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
        <header>
          <label className="title">
            <AutoSizingInput
              value={@state.post.title}
              placeholder={"Tap to add title"}
              onChange={@handleFieldChange('title')}
              onBlur={@handleFieldBlur}
              onKeyUp={@handleFieldKeyup}
              readOnly={@state.company.flags.is_read_only}
            />
          </label>

          <label className="published-at">
            <AutoSizingInput
              value={@state.post.published_at}
              placeholder={"Tap to add publish date"}
              onChange={@handleFieldChange('published-at')}
              onBlur={@handleFieldBlur}
              onKeyUp={@handleFieldKeyup}
              readOnly={@state.company.flags.is_read_only}
            />
          </label>

          <p>
            <a href="" onClick={@handleDestroyClick}>Destroy</a>
          </p>
        </header>


        {blocks}
        {@getSectionPlaceholder(blocks.length)}
      </SortableList>

    else
      null

# Exports
# 
module.exports = Component
