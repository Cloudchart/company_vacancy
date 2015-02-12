# @cjsx React.DOM

GlobalState = require('global_state/state')

# Imports
#
PostStore           = require('stores/post_store')
PostsStoryStore     = require('stores/posts_story_store')
VisibilityStore     = require('stores/visibility_store')
PinStore            = require('stores/pin_store')

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
InsightList         = require('components/insight/list')
Toggle              = require('components/form/toggle')
PinButton           = require('components/pinnable/pin_button')


# Main
#
Post = React.createClass
  
  displayName: 'Post'

  mixins: [GlobalState.mixin]

  # Component specifications
  #
  propTypes:
    id:                    React.PropTypes.string.isRequired
    company_id:            React.PropTypes.string.isRequired
    readOnly:              React.PropTypes.bool
    shouldDisplayViewMode: React.PropTypes.bool

  getDefaultProps: ->
    cursor:
      pins: PinStore.cursor.items
    readOnly:              false
    shouldDisplayViewMode: false

  getInitialState: ->
    _.extend @getStateFromStores(@props),
      readOnly: @props.readOnly
      titleFocused: false

  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    post = PostStore.get(props.id)

    if post
      visibility = VisibilityStore.find (item) -> item.uuid and item.owner_id is props.id and item.owner_type is 'Post'
      titleLength = if (title = post.title) then title.length else 0

      post: post
      titleLength: titleLength
      published_at: @getPublishedAt(post)
      visibility: visibility
      visibility_value: if visibility then visibility.value else 'public'
    else
      post: null

  # Helpers
  #
  getVisibilityOptions: ->
    public:  'Public'
    trusted: 'Trusted'
    only_me: 'Only me'

  getTitleLimit: (length) ->
    140 - length

  getStrippedTitle: (title) ->
    title.replace(/<div>|<\/div>/ig, '')

  update: (attributes) ->
    PostActions.update(@state.post.uuid, attributes)

  getPublishedAt: (post) ->
    if post
      if moment(post.published_at).isValid()
        moment(post.published_at).format('ll')
      else
        ''
    else
      ''


  # Handlers
  #
  handleEffectiveDateUpdate: (from, till) ->
    effective_from = moment(from).format('YYYY-MM-DD')
    effective_till = moment(till).format('YYYY-MM-DD')
    return if @state.post.effective_from is effective_from and @state.post.effective_till is effective_till

    @update({ effective_from: effective_from, effective_till: effective_till })


  handleTitleChange: (content) ->
    @update(title: @getStrippedTitle(content))

  handleTitleBlur: ->
    @setState(titleFocused: false)

  handleTitleFocus: ->
    @setState(titleFocused: true)

  handleTitleInput: (content) ->
    @setState(titleLength: @getStrippedTitle(content).length)

  handleDestroyClick: (event) ->
    if confirm('Are you sure?')
      ModalActions.hide()
      PostActions.destroy(@state.post.uuid)

  handleOkClick: (event) ->
    this.refs.okButton.getDOMNode().focus();
    ModalActions.hide()
    # TODO: show post in timeline

  handleKeydown: (event) ->
    if $(@refs.container.getDOMNode()).find(':focus').length > 0
      if event.metaKey && event.keyCode == 13
        event.preventDefault()
        @handleOkClick()

  handleVisibilityChange: (value) ->
    if @state.visibility and @state.visibility.value isnt value
      VisibilityActions.update(@state.visibility.uuid, { value: value })
    else
      VisibilityActions.create(VisibilityStore.create(), { owner_id: @props.id, value: value })

  handleViewModeChange: (checked) ->
    @setState(readOnly: !checked)


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


  # Renderers
  #
  renderAside: ->
    <aside>
      {
        if !@state.readOnly
          <Dropdown
            options  = { @getVisibilityOptions() }
            value    = { @state.visibility_value }
            onChange = { @handleVisibilityChange }
          />
      }
      {
        if @props.shouldDisplayViewMode
          <Toggle
            checked     = { not @state.readOnly }
            customClass = "cc-toggle view-mode"
            onText      = "Edit"
            offText     = "View"
            onChange    = {@handleViewModeChange}
          />
      }
      <ul className="round-buttons">
        <PinButton 
          pinnable_type = 'Post'
          pinnable_id   = { @state.post.uuid }
          title         = { @state.post.title } />
      </ul>
    </aside>


  renderPins: ->
    return null if PinStore.filterInsightsForPost(@props.id).size == 0

    <div className="post-pins">
      <InsightList pinnable_id={ @props.id } pinnable_type="Post" />
    </div>


  renderButtons: ->
    return null if @state.readOnly

    <div className="controls">
      <button
        className="cc alert"
        onClick={@handleDestroyClick}>
        Delete
      </button>
      <button
        ref="okButton"
        className="cc"
        onClick={@handleOkClick}>
        OK
      </button>
    </div>


  renderEffectiveDate: ->
    <FuzzyDateInput
      from      = { @state.post.effective_from }
      till      = { @state.post.effective_till }
      readOnly  = { @state.readOnly }
      onUpdate  = { @handleEffectiveDateUpdate }
    />


  # Main render
  #
  render: ->
    return null unless @state.post

    <div ref="container" className="post-container">
      { @renderAside() }
      { @renderPins() }

      <header>
        <FieldWrapper className="title">
          <label>
            <ContentEditableArea
              onBlur = { @handleTitleBlur }
              onChange = { @handleTitleChange }
              onFocus = { @handleTitleFocus }
              onInput = { @handleTitleInput }
              placeholder = 'Tap to add title'
              readOnly = { @state.readOnly }
              value = { @state.post.title }
            />
          </label>
          <Counter
            count   = { @getTitleLimit(@state.titleLength) }
            visible = { !@state.readOnly && @state.titleFocused } />
          <Hint
            content = renderHint("title")
            visible = { !@state.readOnly && !@state.titleFocused } />
        </FieldWrapper>

        <FieldWrapper>
          <label className="published-at">
            { @renderEffectiveDate() }
          </label>
          <Hint
            content = { renderHint("date") }
            visible = { !@state.readOnly } />
        </FieldWrapper>

        <FieldWrapper className="categories">
          <PostsStories
            post_id     = { @state.post.uuid }
            company_id  = { @props.company_id }
            readOnly    = { @state.readOnly } />
          <Hint
            content = { renderHint("stories") }
            visible = { !@state.readOnly } />
        </FieldWrapper>
      </header>

      <BlockEditor
        company_id          = {@props.company_id}
        owner_id            = {@state.post.uuid}
        owner_type          = "Post"
        editorIdentityTypes = {['Picture', 'Paragraph', 'Quote', 'KPI', 'Person']}
        classForArticle     = "editor post"
        readOnly            = {@state.readOnly}
      />

      <FieldWrapper className="tags">
        <Tags
          placeholder   = "#event-tag"
          taggable_id   = {@state.post.uuid}
          taggable_type = "Post"
          readOnly      = {@state.readOnly} />
        <Hint
          content = { renderHint("tags") }
          visible = { !@state.readOnly } />
      </FieldWrapper>

      <footer>
        { @renderButtons() }
      </footer>
    </div>

# Exports
#
module.exports = Post
