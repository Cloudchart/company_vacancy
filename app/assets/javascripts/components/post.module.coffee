# @cjsx React.DOM

# Imports
# 
tag = React.DOM

CompanyStore = require('stores/company')
PostStore = require('stores/post_store')
BlockStore = require('stores/block_store')

PostActions = require('actions/post_actions')
BlockableActions = require('actions/mixins/blockable_actions')
ModalActions = require('actions/modal_actions')

Blockable = require('components/mixins/blockable')
SortableList = require('components/shared/sortable_list')
AutoSizingInput = require('components/form/autosizing_input')

# Main
# 
Component = React.createClass

  mixins: [Blockable]

  # Helpers
  # 
  gatherControls: ->
    if @state.company.flags.is_read_only
      null
    else
      <div className="controls">
        <button 
          className="cc alert"
          onClick={@handleDestroyClick}>
          Delete
        </button>

        <button 
          className="cc"
          onClick={@handleOkClick}>
          OK
        </button>
      </div>

  identityTypes: ->
    People:     'Person'
    Vacancies:  'Vacancy'
    Picture:    'Picture'
    Paragraph:  'Paragraph'

  update: (attributes) ->
    PostActions.update(@state.post.uuid, attributes)

  # Handlers
  # 
  handleFieldChange: (name, event) ->
    state = {}
    state[name] = event.target.value
    @setState(state)

  handleTitleBlur: ->
    @update(title: @state.title)

  handlePublishedAtBlur: ->
    if moment(@state.published_at).isValid()
      formatted_value = moment(@state.published_at).format('ll')
      @setState({ published_at: formatted_value })
      @update({ published_at: formatted_value })

  handleFieldKeyup: (event) ->
    event.target.blur() if event.key == 'Enter'

  handleDestroyClick: (event) ->
    if confirm('Are you sure?')
      ModalActions.hide()
      PostActions.destroy(@state.post.uuid)

  handleOkClick: (event) ->
    ModalActions.hide()
    # TODO: show post in timeline

  # Lifecycle Methods
  # 
  # componentWillMount: ->

  componentDidMount: ->
    BlockStore.on('change', @refreshStateFromStores)

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores())

  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->

  componentWillUnmount: ->
    BlockStore.off('change', @refreshStateFromStores)

  # Component Specifications
  # 
  getTitle: (post) ->
    if post then post.title else ''

  getPublishedAt: (post) ->
    if post 
      if moment(post.published_at).isValid()
        moment(post.published_at).format('ll') 
      else
        ''
    else
      ''

  refreshStateFromStores: ->
    @setState(@getStateFromStores())

  getStateFromStores: ->
    post = PostStore.get(@props.id)

    company: CompanyStore.get(@props.company_id)
    post: post
    blocks: BlockStore.filter (block) => block.owner_type == 'Post' and block.owner_id == @props.id
    title: @getTitle(post)
    published_at: @getPublishedAt(post)

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
              value={@state.title}
              placeholder={"Tap to add title"}
              onChange={@handleFieldChange.bind(@, 'title')}
              onBlur={@handleTitleBlur}
              onKeyUp={@handleFieldKeyup}
              readOnly={@state.company.flags.is_read_only}
            />
          </label>

          <label className="published-at">
            <AutoSizingInput
              value={@state.published_at}
              placeholder={moment().format('ll')}
              onChange={@handleFieldChange.bind(@, 'published_at')}
              onBlur={@handlePublishedAtBlur}
              onKeyUp={@handleFieldKeyup}
              readOnly={@state.company.flags.is_read_only}
            />
          </label>
        </header>

        {blocks}
        {@getSectionPlaceholder(blocks.length)}
        {@gatherControls()}
      </SortableList>

    else
      null

# Exports
# 
module.exports = Component
