# @cjsx React.DOM

# Imports
# 
tag = React.DOM

PostStore = require('stores/post_store')

PostActions = require('actions/post_actions')
ModalActions = require('actions/modal_actions')

StoriesComponent    = require('components/company/stories')
BlockEditor         = require('components/editor/block_editor')
FuzzyDateInput      = require('components/form/fuzzy_date_input')
ContentEditableArea = require('components/form/contenteditable_area')

# Main
# 
Component = React.createClass

  # mixins: []

  # Helpers
  # 
  gatherControls: ->
    return null if @props.readOnly

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


  effectiveDate: ->
    <FuzzyDateInput
      from      = { @state.post.effective_from }
      till      = { @state.post.effective_till }
      onUpdate  = { @handleEffectiveDateUpdate }
    />


  update: (attributes) ->
    PostActions.update(@state.post.uuid, attributes)


  # Handlers
  # 
  handleEffectiveDateUpdate: (from, till) ->
    effective_from = moment(from).format('YYYY-MM-DD')
    effective_till = moment(till).format('YYYY-MM-DD')
    return if @state.post.effective_from is effective_from and @state.post.effective_till is effective_till

    @update({ effective_from: effective_from, effective_till: effective_till })
  

  handleTitleChange: (content) ->
    return if content is @state.post.title
    @update(title: content)


  handleDestroyClick: (event) ->
    if confirm('Are you sure?')
      ModalActions.hide()
      PostActions.destroy(@state.post.uuid)

  handleOkClick: (event) ->
    ModalActions.hide()
    # TODO: show post in timeline

  handleStoriesChange: (story_ids) ->
    PostActions.update(@state.post.uuid, { story_ids: story_ids })

  # Lifecycle Methods
  # 
  componentDidMount: ->
    PostStore.on('change', @refreshStateFromStores)

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  componentWillUnmount: ->
    PostStore.off('change', @refreshStateFromStores)

  # Component Specifications
  # 
  getPublishedAt: (post) ->
    if post 
      if moment(post.published_at).isValid()
        moment(post.published_at).format('ll')
      else
        ''
    else
      ''

  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    post = PostStore.get(props.id)

    post: post
    published_at: @getPublishedAt(post)

  getInitialState: ->
    @getStateFromStores(@props)

  render: ->
    return null unless @state.post

    <div className="post-container">
      <header>
        <label className="title">
          <ContentEditableArea
            onChange = { @handleTitleChange }
            placeholder = 'Tap to add title'
            readOnly = { @props.readOnly }
            value = { @state.post.title }
          />
        </label>

        <label className="published-at">
          { @effectiveDate() }
        </label>

        <StoriesComponent
          post_id = {@state.post.uuid}
          company_id = {@props.company_id}
          onChange = {@handleStoriesChange}
          readOnly = {@props.readOnly}
        />
      </header>

      <BlockEditor
        company_id = {@props.company_id}
        owner_id = {@state.post.uuid}
        owner_type = "Post"
        editorIdentityTypes = {['Picture', 'Paragraph', 'Quote', 'KPI', 'Person']}
        classForArticle = "editor post"
        buildParagraph = {true}
        readOnly = {@props.readOnly}
      />

      <footer>
        {@gatherControls()}
      </footer>
    </div>

# Exports
# 
module.exports = Component
