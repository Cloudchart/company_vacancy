# @cjsx React.DOM

# Imports
# 
PostStore           = require('stores/post_store')
PostsStoryStore     = require('stores/posts_story_store')
VisibilityStore     = require('stores/visibility_store')

PostActions         = require('actions/post_actions')
VisibilityActions   = require('actions/visibility_actions')
ModalActions        = require('actions/modal_actions')

PostsStories        = require('components/posts_stories')
Tags                = require('components/company/tags')
BlockEditor         = require('components/editor/block_editor')
FuzzyDateInput      = require('components/form/fuzzy_date_input')
ContentEditableArea = require('components/form/contenteditable_area')

Dropdown            = require('components/form/dropdown')
FieldWrapper        = require('components/editor/field_wrapper')
Counter             = require('components/shared/counter')
Hint                = require('components/shared/hint')
renderHint          = require('utils/render_hint')


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

  getVisibilityOptions: ->
    public:  'Public'
    trusted: 'Trusted'
    only_me: 'Only me'

  effectiveDate: ->
    <FuzzyDateInput
      from      = { @state.post.effective_from }
      till      = { @state.post.effective_till }
      readOnly  = { @props.readOnly }
      onUpdate  = { @handleEffectiveDateUpdate }
    />

  stripHTML: (content) ->
    tmp = document.createElement("DIV")
    tmp.innerHTML = content
    tmp.textContent || tmp.innerText || ""

  getTitleLength: (title) ->
    @stripHTML(title).length

  getTitleLimit: (length) ->
    140 - length

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

  handleTitleBlur: ->
    @setState(titleFocused: false)

  handleTitleFocus: ->
    @setState(titleFocused: true)

  handleTitleInput: (content) ->
    @setState(titleLength: @getTitleLength(content))

  handleDestroyClick: (event) ->
    if confirm('Are you sure?')
      ModalActions.hide()
      PostActions.destroy(@state.post.uuid)

  handleOkClick: (event) ->
    ModalActions.hide()
    # TODO: show post in timeline

  handleKeydown: (event) ->
    if event.keyCode == 27
      event.preventDefault()
      ModalActions.hide()

    if event.metaKey && event.keyCode == 13
      event.preventDefault()
      @handleOkClick()

  handleVisibilityChange: (value) ->
    if @state.visibility and @state.visibility.value isnt value
      VisibilityActions.update(@state.visibility.uuid, { value: value })
    else
      VisibilityActions.create(VisibilityStore.create(), { owner_id: @props.id, value: value })


  # Lifecycle Methods
  # 
  componentDidMount: ->
    $(document).on 'keydown', @handleKeydown
    PostStore.on('change', @refreshStateFromStores)
    VisibilityStore.on('change', @refreshStateFromStores)


  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  componentWillUnmount: ->
    $(document).off 'keydown', @handleKeydown
    PostStore.off('change', @refreshStateFromStores)
    VisibilityStore.off('change', @refreshStateFromStores)

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
    visibility = VisibilityStore.find (item) -> item.uuid and item.owner_id is props.id and item.owner_type is 'Post'
    post = PostStore.get(props.id)

    titleLength = if (title = post.title) then @getTitleLength(title) else 0

    post: post
    titleLength:  titleLength
    published_at: @getPublishedAt(post)
    visibility: visibility
    visibility_value: if visibility then visibility.value else 'public'


  getInitialState: ->
    _.extend @getStateFromStores(@props),
      titleFocused: false

  render: ->
    return null unless @state.post

    <div className="post-container">
      <aside>
        <Dropdown 
          options  = { @getVisibilityOptions() }
          value    = { @state.visibility_value }
          onChange = { @handleVisibilityChange } />
      </aside>

      <header>
        <FieldWrapper className="title">
          <label>
            <ContentEditableArea
              onBlur = { @handleTitleBlur }
              onChange = { @handleTitleChange }
              onFocus = { @handleTitleFocus }
              onInput = { @handleTitleInput }
              placeholder = 'Tap to add title'
              readOnly = { @props.readOnly }
              value = { @state.post.title }
            />
          </label>
          <Counter 
            count   = { @getTitleLimit(@state.titleLength) }
            visible = { !@props.readOnly && @state.titleFocused } />
          <Hint
            content = renderHint("title")
            visible = { !@props.readOnly && !@state.titleFocused } />
        </FieldWrapper>

        <FieldWrapper>
          <label className="published-at">
            { @effectiveDate() }
          </label>
          <Hint 
            content = { renderHint("date") }
            visible = { !@props.readOnly } />
        </FieldWrapper>

        <FieldWrapper className="categories">
          <PostsStories
            post_id     = { @state.post.uuid }
            company_id  = { @props.company_id }
            readOnly    = { @props.readOnly }
            placeholder = "Category" />
          <Hint 
            content = { renderHint("stories") }
            visible = { !@props.readOnly } />
        </FieldWrapper>
      </header>

      <BlockEditor
        company_id          = {@props.company_id}
        owner_id            = {@state.post.uuid}
        owner_type          = "Post"
        editorIdentityTypes = {['Picture', 'Paragraph', 'Quote', 'KPI', 'Person']}
        classForArticle     = "editor post"
        readOnly            = {@props.readOnly}
      />

      <FieldWrapper className="tags">
        <Tags
          placeholder   = "#storytag"
          taggable_id   = {@state.post.uuid}
          taggable_type = "Post"
          readOnly      = {@props.readOnly} />
        <Hint 
          content = { renderHint("tags") }
          visible = { !@props.readOnly } />
      </FieldWrapper>

      <footer>
        {@gatherControls()}
      </footer>
    </div>

# Exports
# 
module.exports = Component
