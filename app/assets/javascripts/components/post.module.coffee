# @cjsx React.DOM

GlobalState = require('global_state/state')

cx = React.addons.classSet

# Imports
#
CompanyStore        = require('stores/company')
PostStore           = require('stores/post_store')
PostsStoryStore     = require('stores/posts_story_store')
VisibilityStore     = require('stores/visibility_store')
PinStore            = require('stores/pin_store')
UserStore           = require('stores/user_store.cursor')

PostActions         = require('actions/post_actions')
VisibilityActions   = require('actions/visibility_actions')
ModalActions        = require('actions/modal_actions')

PostsStories        = require('components/posts_stories')
BlockEditor         = require('components/editor/block_editor')
FuzzyDateInput      = require('components/form/fuzzy_date_input')
ContentEditableArea = require('components/form/contenteditable_area')

Dropdown            = require('components/form/dropdown')
Wrapper             = require('components/shared/wrapper')
Counter             = require('components/shared/counter')
Hint                = require('components/shared/hint')
renderHint          = require('utils/render_hint')
InsightList         = require('components/insight/list')
Toggle              = require('components/form/toggle')
PinButton           = require('components/pinnable/pin_button')
StandardButton      = require('components/form/buttons').StandardButton
UserPreview         = require('components/user/preview')

# Main
#
Post = React.createClass
  
  displayName: 'Post'

  mixins: [GlobalState.mixin]

  statics: 
    getCursor: (company_id) ->
      pins:   PinStore.cursor.items
      users:  UserStore.cursor.items
      flags:  GlobalState.cursor(['stores', 'companies', 'flags', company_id])


  # Component specifications
  #
  propTypes:
    id:          React.PropTypes.string.isRequired
    company_id:  React.PropTypes.string.isRequired
    readOnly:    React.PropTypes.bool

  getDefaultProps: ->
    readOnly: true

  getInitialState: ->
    _.extend @getStateFromStores(@props),
      readOnly:        @props.readOnly
      isInEditMode:    false
      arePinsExpanded: false
      titleFocused:    false

  onGlobalStateChange: ->
    readOnly = @props.cursor.flags.get('is_read_only')
    isInEditMode = isInEditMode && !readOnly

    @setState(readOnly: readOnly, isInEditMode: isInEditMode)

  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    post = PostStore.get(props.id)

    if post
      visibility = VisibilityStore.find (item) -> item.uuid and item.owner_id is props.id and item.owner_type is 'Post'
      titleLength = if (title = post.title) then title.length else 0

      post: post
      company: CompanyStore.get(props.company_id)
      titleLength: titleLength
      published_at: @getPublishedAt(post)
      visibility: visibility
      visibility_value: if visibility then visibility.value else 'unpublished'
    else
      post: null


  # Helpers
  #
  getVisibilityOptions: ->
    options = {}
    options.unpublished = 'Unpublished' unless @state.visibility
    options.public = 'Public'
    options.trusted = 'Trusted'
    options.only_me = 'Only me'
    options


  getViewModeOptions: ->
    view: 'View'
    edit: 'Edit'

  getTitleLimit: (length) ->
    140 - length

  getStrippedTitle: (title) ->
    title.replace(/(<([^>]+)>)/ig, "").trim()

  gatherPinnersIds: ->
    PinStore.filterPinsForPost(@props.id)
      .sortBy (pin) -> pin.get('created_at')
      .reverse()
      .map (pin) -> pin.get('user_id')

  getPinnersNumberText: (pinnersNumber) ->
    if pinnersNumber > 0 then "+ #{pinnersNumber} others pinned this post" else null

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
      PostActions.destroy(@state.post.uuid)
      location.href = @state.company.company_url

  handleOkClick: (event) ->
    this.refs.okButton.getDOMNode().focus();
    location.href = @state.company.company_url + "#" + @props.id
    
    unless @state.visibility
      VisibilityActions.create(VisibilityStore.create(), { owner_id: @props.id, value: 'public' })

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

  handleViewModeChange: (value) ->
    @setState(isInEditMode: value == 'edit')

  handleExpandPins: ->
    @setState(arePinsExpanded: true)

    setTimeout ->
      $('html,body').animate({ scrollTop: $(".post-pins").offset().top - 30 }, 'slow')
    , 10


  # Lifecycle Methods
  #
  componentDidMount: ->
    $(document).on 'keydown', @handleKeydown
    PostStore.on('change', @refreshStateFromStores)
    CompanyStore.on('change', @refreshStateFromStores)
    VisibilityStore.on('change', @refreshStateFromStores)

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  componentWillUnmount: ->
    $(document).off 'keydown', @handleKeydown
    PostStore.off('change', @refreshStateFromStores)
    CompanyStore.on('change', @refreshStateFromStores)
    VisibilityStore.off('change', @refreshStateFromStores)


  # Renderers
  #
  renderCompanyName: ->
    return null unless @state.company

    <h2>{ @state.company.name }</h2>

  renderVisibilityDropdown: ->
    return null unless @state.isInEditMode

    <Dropdown
      key      = "visibility"
      options  = { @getVisibilityOptions() }
      value    = { @state.visibility_value }
      onChange = { @handleVisibilityChange } />

  renderEditControl: ->
    return null if @state.readOnly

    if @state.isInEditMode
      <Dropdown
        key         = "view-mode"
        options     = { @getViewModeOptions() }
        value       = "edit"
        className   = "view-mode"
        iconClass   = "fa fa-chevron-down"
        onChange    = { @handleViewModeChange } />
    else
      <StandardButton 
        className = "edit-mode transparent"
        onClick   = { => @handleViewModeChange("edit") }
        text      = "edit" />

  renderCloseIcon: ->
    return null unless @state.company

    if @state.isInEditMode
      <StandardButton 
        className = "transparent"
        iconClass = "cc-icon cc-times"
        onClick   = { => @handleViewModeChange("view") } />
    else
      <a href={ @state.company.get('company_url') + "#" + @props.id }>
        <i className="cc-icon cc-times"></i>
      </a>

  renderHeaderControls: ->
    <section className="controls">
      { @renderVisibilityDropdown() }
      { @renderEditControl() }
      { @renderCloseIcon() }
    </section>

  renderExpandButton: ->
    return null if @state.arePinsExpanded

    <StandardButton 
      className = "cc show-pins"
      onClick   = { @handleExpandPins }
      text      = "Show All" />

  renderPins: ->
    return null if PinStore.filterInsightsForPost(@props.id).size == 0 || @state.isInEditMode

    className = cx("post-pins": true, expanded: @state.arePinsExpanded)

    <section className={ className }>
      <InsightList 
        onlyFirst     = { !@state.arePinsExpanded }
        pinnable_id   = { @props.id }
        pinnable_type = "Post" />
      { @renderExpandButton() }
    </section>

  renderPinners: (pinners) ->
    return null if PinStore.filterPinsForPost(@props.id).size == 0 || @state.isInEditMode

    pinnersIds = @gatherPinnersIds()
    
    pinners = pinnersIds.take(3).map (pinnerId) => @props.cursor.users.get(pinnerId)
    pinnersNumber = pinnersIds.skip(3).size

    <section className="post-pinners">
      <ul>
        {
          pinners.map (user, index) ->
            <li key={index}>
              <UserPreview cursor = { UserPreview.getCursor(user.get('uuid')) } />
            </li>
          .toArray()
        }
      </ul>
      { @getPinnersNumberText(pinnersNumber) }
    </section>


  renderPinInfo: ->
    return null if @state.isInEditMode

    <section className="post-pin-info">
      { @renderPinners() }
      <ul className="round-buttons">
        <PinButton 
          pinnable_id   = { @props.id }
          pinnable_type = 'Post'
          title         = { @state.post.title } />
      </ul>
    </section>


  renderFooter: ->
    return null unless @state.isInEditMode

    <footer>
      <StandardButton
        className = "cc alert"
        onClick   = { @handleDestroyClick }
        text      = "Delete" />
      <StandardButton
        ref       = "okButton"
        className = "cc"
        onClick   = { @handleOkClick }
        text      = "OK" />
    </footer>

  renderEffectiveDate: ->
    <FuzzyDateInput
      from      = { @state.post.effective_from }
      till      = { @state.post.effective_till }
      readOnly  = { !@state.isInEditMode }
      onUpdate  = { @handleEffectiveDateUpdate }
    />


  # Main render
  #
  render: ->
    return null unless @state.post

    className = cx({
      "post-container": true,
      edit: @state.isInEditMode
    })

    <article ref="container" className={ className } >

      <header>
        { @renderCompanyName() }
        <Wrapper className="editor" isWrapped={!@state.isInEditMode}>
          <label className="title">
            <ContentEditableArea
              onBlur = { @handleTitleBlur }
              onChange = { @handleTitleChange }
              onFocus = { @handleTitleFocus }
              onInput = { @handleTitleInput }
              placeholder = 'Tap to add title'
              readOnly = { !@state.isInEditMode }
              value = { @state.post.title }
            />
          </label>
          <Counter
            count   = { @getTitleLimit(@state.titleLength) }
            visible = { @state.isInEditMode && @state.titleFocused } />
          <Hint
            content = renderHint("title")
            visible = { @state.isInEditMode && !@state.titleFocused } />
        </Wrapper>

        <Wrapper className="editor" isWrapped={@state.isInEditMode}>
          <label className="published-at">
            { @renderEffectiveDate() }
          </label>
          <Hint
            content = { renderHint("date") }
            visible = { @state.isInEditMode } />
        </Wrapper>

        <Wrapper className="editor" isWrapped={@state.isInEditMode}>
          <PostsStories
            post_id     = { @state.post.uuid }
            company_id  = { @props.company_id }
            readOnly    = { !@state.isInEditMode } />
          <Hint
            content = { renderHint("stories") }
            visible = { @state.isInEditMode } />
        </Wrapper>

        { @renderHeaderControls() }
      </header>
      
      { @renderPinInfo() }

      <section className="content">
        <BlockEditor
          company_id          = {@props.company_id}
          owner_id            = {@state.post.uuid}
          owner_type          = "Post"
          editorIdentityTypes = {['Picture', 'Paragraph', 'Quote', 'KPI', 'Person']}
          classForArticle     = "editor post"
          readOnly            = {!@state.isInEditMode}
        />
        { @renderFooter() }
      </section>

      { @renderPins() }
    </article>

# Exports
#
module.exports = Post
