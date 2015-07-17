# @cjsx React.DOM

# Imports
# 
cx  = React.addons.classSet

CloudFlux = require('cloud_flux')
GlobalState = require('global_state/state')

CompanyStore   = require('stores/company')
PostStore      = require('stores/post_store')
PinStore       = require('stores/pin_store')
StoryStore     = require('stores/story_store')
PostsStoryStore = require('stores/posts_story_store')
VisibilityStore = require('stores/visibility_store')

PostActions = require('actions/post_actions')

PostPreview         = require('components/company/timeline/post_preview')
Post                = require('components/post')
ContentEditableArea = require('components/form/contenteditable_area')
StoriesList         = require('components/story/list')
StandardButton      = require('components/form/buttons').StandardButton


# Utils
#
postVisibilityPredicate = (component) ->
  (post) ->
    isPersisted = post.uuid and post.created_at != post.updated_at
    hasVisibility = VisibilityStore.find((item) -> item.owner_id is post.uuid)

    if component.props.readOnly and component.state.story
      post.story_ids.contains(component.state.story.get('uuid')) and hasVisibility and isPersisted
    else if component.props.readOnly
      hasVisibility and isPersisted
    else
      isPersisted


# Main
# 
Component = React.createClass

  displayName: 'CompanyTimeline'

  propTypes:
    company_id: React.PropTypes.string.isRequired
    readOnly: React.PropTypes.bool
  
  mixins: [CloudFlux.mixins.Actions, GlobalState.mixin]

  statics:
    isEmpty: (company_id) ->
      !PostStore.all().length


  # Component Specifications
  # 
  getDefaultProps: ->
    cursor:
      stories: StoryStore.cursor.items
      # posts_stories: PostsStoryStore.cursor.items
      # pins: PinStore.cursor.items
    readOnly: true

  getInitialState: ->
    _.extend @getStateFromStores(@props),
      new_post_key:         null
      shouldDisplayStories: @shouldDisplayStories()
      story:                @getCurrentStory()

  onGlobalStateChange: ->
    @setState story: @getCurrentStory()

  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    company: CompanyStore.get(props.company_id)
    posts:   PostStore.all()
    postSeq: Immutable.Seq(PostStore.all())

  getCloudFluxActions: ->
    'post:create:done': @handlePostCreateDone


  # Helpers
  #
  getPosts: ->
    # TODO: fix sortBy when there is new post with blank visibility and effective_from

    @state.postSeq
      .filter postVisibilityPredicate(@)
      .sortBy (post) -> post.effective_till + +(post.effective_till != post.effective_from)
      .map    @renderPost(@props)
      .reverse()

  isLoaded: ->
    @state.posts and @props.cursor.stories.deref(false)

  getCurrentStory: ->
    if location.hash.match(/^#story/)
      @props.cursor.stories.find (story) -> story.get('name') is location.hash.split(/#story-/).pop() || null
    else
      null

  shouldDisplayStories: ->
    !!location.hash.match(/^#stories/)

  scrollToPost: ->
    headerHeight = $('body > header').height()

    if (id = location.hash) && $(id).length > 0
      $(document).scrollTop(parseInt($(id).offset().top) - (10 + headerHeight))
      history.replaceState('', document.title, window.location.pathname)


  # Handlers
  #
  handleCreatePostClick: (event) ->
    return if PostStore.getSync(@state.new_post_key) == "create"

    new_post_key = PostStore.create()
    PostActions.create(new_post_key, { owner_id: @props.company_id, owner_type: 'Company' })

    @setState({ new_post_key: new_post_key })


  handlePostCreateDone: (id, attributes, json, sync_token) ->
    window.location.href = json.post_url

  handleHashChange: ->
    @setState 
      story: @getCurrentStory()
      shouldDisplayStories: @shouldDisplayStories()

  handleStoryDescriptionChange: (value) ->
    StoryStore.update(@state.story.get('uuid'), description: value)

  handleStoriesListClick: (event) ->
    location.hash = 'stories'


  # Lifecycle Methods
  # 
  componentDidMount: ->
    @scrollToPost()
    CompanyStore.on('change', @refreshStateFromStores)
    window.addEventListener 'hashchange', @handleHashChange

  componentWillUpdate: ->
    @scrollToPost()

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)
    window.removeEventListener 'hashchange', @handleHashChange


  # Renderers
  #
  renderCreatePostButton: (type = '') ->
    return null if @props.readOnly
      
    iconClasses =
      if PostStore.getSync(@state.new_post_key) == "create"
        'fa fa-spin fa-spinner'
      else
        'cc-icon cc-plus'

    placeholderClasses = cx({
      placeholder: true
      small: type == 'small'
    })
 
    <div className={placeholderClasses}>
      <figure onClick={@handleCreatePostClick} >
        <i className={iconClasses}></i>
      </figure>
    </div>

  renderPost: (props) ->
    (post) =>
      <PostPreview
        key          = { post.uuid }
        uuid         = { post.uuid }
        story        = { @state.story }
        readOnly     = { @props.readOnly }
      />

  renderStoryChevron: ->
    return null if @state.story

    <i className="fa fa-chevron-down" />

  renderStoryCancel: ->
    return null unless @state.story

    <StandardButton
      className = "transparent"
      iconClass = "cc-icon cc-times"
      onClick   = { -> location.hash = 'timeline' } />

  renderStoryName: ->
    storyName = if @state.story
      "#" + @state.story.get('formatted_name')
    else
      "all events"

    <h1>
      <span>
        { "Showing " }
        <span className="link" onClick = { @handleStoriesListClick }>
          { storyName }
          { @renderStoryChevron() }
        </span>
      </span>
      { @renderStoryCancel() }
    </h1>

  renderStoryDescription: ->
    return null unless @state.story

    if @state.story.get('company_id') and !@props.readOnly
      <label className="description">
        <ContentEditableArea
          onChange = { @handleStoryDescriptionChange }
          placeholder = 'Tap to add description'
          readOnly = { @props.readOnly }
          value = { @state.story.get('description') }
        />
      </label>
    else
      <div className="description" dangerouslySetInnerHTML={__html: @state.story.get('description')} />

  renderCurrentStory: ->
    return null unless @getPosts().size > 0

    <header>
      { @renderStoryName() }
      { @renderStoryDescription() }
    </header>

  renderPosts: (posts) ->
    if posts.count() > 0
      posts.toArray()
    else if !@props.readOnly
      <div className="instruction">
        You have no posts on your timeline.<br />
        Let’s add some by pressing plus button.
      </div>
    else
      null


  # Main render
  # 
  render: ->
    return null unless @isLoaded()
    return <StoriesList company_id = { @props.company_id } readOnly = { @props.readOnly } /> if @state.shouldDisplayStories

    posts = @getPosts()

    posts = posts.map (post, index) =>
      [
        post
        @renderCreatePostButton('small')
      ]

    <section className="timeline wrapper">
      { @renderCurrentStory() }

      <section className="timeline posts">
        { @renderCreatePostButton() }
        { @renderPosts(posts) }
      </section>
    </section>


# Exports
# 
module.exports = Component
