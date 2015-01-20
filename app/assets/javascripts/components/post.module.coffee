# @cjsx React.DOM

# Imports
# 
PostStore = require('stores/post_store')

PostActions = require('actions/post_actions')
ModalActions = require('actions/modal_actions')

StoriesComponent    = require('components/company/stories')
BlockEditor         = require('components/editor/block_editor')
FuzzyDateInput      = require('components/form/fuzzy_date_input')
ContentEditableArea = require('components/form/contenteditable_area')

FieldWrapper        = require('components/editor/field_wrapper')
Counter             = require('components/shared/counter')
Hint                = require('components/shared/hint')
HintTexts           = require('utils/hint_texts')

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

    titleLength = if (title = post.title) then @getTitleLength(title) else 0

    post: post
    titleLength:  titleLength
    published_at: @getPublishedAt(post)

  getInitialState: ->
    _.extend @getStateFromStores(@props),
      titleFocused: false

  render: ->
    return null unless @state.post

    <div className="post-container">
      <header>
        <FieldWrapper>
          <label className="title">
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
          {
            if (!@props.readOnly && @state.titleFocused)
              <Counter count={ @getTitleLimit(@state.titleLength) } />
          }
          {
            if (!@props.readOnly && !@state.titleFocused)
              <Hint text={HintTexts.title} />
          }
        </FieldWrapper>

        <FieldWrapper>
          <label className="published-at">
            { @effectiveDate() }
          </label>
          {
            if !@props.readOnly
              <Hint text={HintTexts.date} />
          }
        </FieldWrapper>

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
        readOnly = {@props.readOnly}
      />

      <footer>
        {@gatherControls()}
      </footer>
    </div>

# Exports
# 
module.exports = Component
