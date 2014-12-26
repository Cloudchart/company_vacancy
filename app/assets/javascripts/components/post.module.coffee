# @cjsx React.DOM

# Imports
# 
tag = React.DOM

PostStore = require('stores/post_store')

PostActions = require('actions/post_actions')
ModalActions = require('actions/modal_actions')

AutoSizingInput = require('components/form/autosizing_input')
TagsComponent   = require('components/company/tags')
BlockEditor     = require('components/editor/block_editor')
FuzzyDateInput  = require('components/form/fuzzy_date_input')

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
  handleFieldChange: (name, event) ->
    state = {}
    state[name] = event.target.value
    @setState(state)


  handleTitleBlur: ->
    @update(title: @state.title)


  # handlePublishedAtBlur: ->
  #   published_at = Date.parse @state.published_at
  #
  #   if moment(published_at).isValid()
  #     @update({ published_at: moment(published_at).format('ll') })
  
  
  handleEffectiveDateUpdate: (from, till) ->
    @update({ effective_from: moment(from).format('YYYY-MM-DD'), effective_till: moment(till).format('YYYY-MM-DD') })
  

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
  componentDidMount: ->
    PostStore.on('change', @refreshStateFromStores)

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  componentWillUnmount: ->
    PostStore.off('change', @refreshStateFromStores)

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
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    post = PostStore.get(props.id)

    post: post
    title: @getTitle(post)
    published_at: @getPublishedAt(post)

  getInitialState: ->
    state = @getStateFromStores(@props)
    state

  render: ->
    return null unless @state.post

    <div className="post-container">
      <header>
        <label className="title">
          <AutoSizingInput
            value={@state.title}
            placeholder={"Tap to add title"}
            onChange={@handleFieldChange.bind(@, 'title')}
            onBlur={@handleTitleBlur}
            onKeyUp={@handleFieldKeyup}
            readOnly={@props.readOnly}
          />
        </label>

        <label className="published-at">
          { @effectiveDate() }
        </label>

        <TagsComponent taggable_id={@state.post.uuid} taggable_type="Post" readOnly={@props.readOnly} />
      </header>

      <BlockEditor
        company_id = {@props.company_id}
        owner_id = {@state.post.uuid}
        owner_type = "Post"
        editorIdentityTypes = {['Person', 'Vacancy', 'Picture', 'Paragraph']}
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
