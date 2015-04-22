# @cjsx React.DOM

# Imports
# 
cx  = React.addons.classSet

CloudFlux = require('cloud_flux')
GlobalState = require('global_state/state')

PostStore = require('stores/post_store')
PinStore  = require('stores/pin_store')
StoryStore = require('stores/story_store')
PostsStoryStore = require('stores/posts_story_store')
VisibilityStore = require('stores/visibility_store')

PostActions = require('actions/post_actions')

PostPreview = require('components/company/timeline/post_preview')
Post = require('components/post')


# Utils
#
postVisibilityPredicate = (component) ->
  (post) ->
    isPersisted = post.uuid and post.created_at != post.updated_at
    hasVisibility = VisibilityStore.find((item) -> item.owner_id is post.uuid)

    if component.props.readOnly and component.state.story_id
      post.story_ids.contains(component.state.story_id) and hasVisibility and isPersisted
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
      # pins: PinStore.cursor.items
      stories: StoryStore.cursor.items
      # posts_stories: PostsStoryStore.cursor.items
    readOnly: true

  getInitialState: ->
    state                = @getStateFromStores(@props)
    state.new_post_key   = null
    # state.anchorScrolled = false
    state.story_id       = null
    state

  onGlobalStateChange: ->
    @setState refreshed_at: + new Date

  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    posts:      PostStore.all()
    postSeq:    Immutable.Seq(PostStore.all())

  getCloudFluxActions: ->
    'post:create:done': @handlePostCreateDone


  # Helpers
  #
  getPosts: ->
    # TODO: fix sortBy when there is new post with blank visibility and effective_from

    @state.postSeq
      .filter postVisibilityPredicate(@)
      .sortBy (post) -> post.effective_from
      .map    @renderPost(@props)
      .reverse()

  isLoaded: ->
    @state.posts and @props.cursor.stories.deref(false)

  updateCurrentStory: ->
    if location.hash.match(/^#story/)
      story = @props.cursor.stories.find (story) -> story.get('formatted_name') is location.hash.split(/#story-/).pop()
      @setState story_id: story.get('uuid') if story
    else
      @setState story_id: null


  # Handlers
  #
  handleCreatePostClick: (event) ->
    return if PostStore.getSync(@state.new_post_key) == "create"

    new_post_key = PostStore.create()
    PostActions.create(new_post_key, { owner_id: @props.company_id, owner_type: 'Company' })

    @setState({ new_post_key: new_post_key })


  handlePostCreateDone: (id, attributes, json, sync_token) ->
    window.location.href = json.post_url

  handleStoryClick: (story) ->
    if @state.story_id != story.get('uuid')
      location.hash = "story-#{story.get('formatted_name')}"

  handleHashChange: ->
    @updateCurrentStory()

  # Lifecycle Methods
  # 
  componentWillMount: ->
    @updateCurrentStory()
    
  componentDidMount: ->
    window.addEventListener 'hashchange', @handleHashChange
    # PostStore.on('change', @refreshStateFromStores)
    # VisibilityStore.on('change', @refreshStateFromStores)

  # componentDidUpdate: ->
    # if (id = location.hash) && !@state.anchorScrolled && $(id).length > 0
    #   $(document).scrollTop(parseInt($(id).offset().top) - 30)
    #   @setState(anchorScrolled: true)

  # componentWillReceiveProps: (nextProps) ->
  #   @setState(@getStateFromStores(nextProps))


  componentWillUnmount: ->
    window.removeEventListener 'hashchange', @handleHashChange
    # PostStore.off('change', @refreshStateFromStores)
    # VisibilityStore.off('change', @refreshStateFromStores)


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
        onStoryClick = { @handleStoryClick }
        story_id     = { @state.story_id }
        readOnly     = { @props.readOnly }
      />

  renderCurrentStory: ->
    return null unless @state.story_id

    <header>
      <h1></h1>
      <div className="description"></div>
    </header>

  # Main render
  # 
  render: ->
    return null unless @isLoaded()

    posts = @getPosts()

    unless posts.count() == 0
      posts = posts.map (post, index) =>
        [
          post
          @renderCreatePostButton('small')
        ]

      <section className="timeline posts">
        { @renderCreatePostButton() }
        { posts.toArray() }
      </section>
    else if !@props.readOnly
      <section className="timeline posts">
        { @renderCreatePostButton() }
        <div className="instruction">
          You have no posts on your timeline.<br />
          Let’s add some by pressing plus button.
        </div>
      </section>
    else
      null


# Exports
# 
module.exports = Component
