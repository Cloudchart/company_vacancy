# @cjsx React.DOM

# Imports
# 
tag = React.DOM
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
    if component.props.readOnly
      VisibilityStore.find((item) -> item.owner_id is post.uuid) and
      post.uuid and post.created_at != post.updated_at
    else
      post.uuid and post.created_at != post.updated_at


# Main
# 
Component = React.createClass

  mixins: [CloudFlux.mixins.Actions, GlobalState.mixin]

  # Component Specifications
  # 
  displayName: "Timeline"

  propTypes:
    company_id:   React.PropTypes.string.isRequired
    onStoryClick: React.PropTypes.func
    readOnly:     React.PropTypes.bool

  getDefaultProps: ->
    cursor:
      pins: PinStore.cursor.items
      stories: StoryStore.cursor.items
      posts_stories: PostsStoryStore.cursor.items
    onStoryClick: ->
    readOnly: true

  getInitialState: ->
    state                = @getStateFromStores(@props)
    state.new_post_key   = null
    state.anchorScrolled = false
    state

  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    posts:      PostStore.all()
    postSeq:    Immutable.Seq(PostStore.all())


  # Helpers
  #
  getPosts: ->
    @state.postSeq
      .filter postVisibilityPredicate(@)
      .sortBy (post) -> post.effective_from
      .map    @renderPost(@props)
      .reverse()

  getCloudFluxActions: ->
    'post:create:done': @handlePostCreateDone


  # Handlers
  #
  handleCreatePostClick: (event) ->
    return if PostStore.getSync(@state.new_post_key) == "create"

    new_post_key = PostStore.create()
    PostActions.create(new_post_key, { owner_id: @props.company_id, owner_type: 'Company' })

    @setState({ new_post_key: new_post_key })


  handlePostCreateDone: (id, attributes, json, sync_token) ->
    window.location.href = json.post_url


  # Lifecycle Methods
  # 
  onGlobalStateChange: ->
    @setState
      refreshed_at: + new Date


  componentDidMount: ->
    PostStore.on('change', @refreshStateFromStores)
    # VisibilityStore.on('change', @refreshStateFromStores)

  componentDidUpdate: ->
    if (id = location.hash) && !@state.anchorScrolled && $(id).length > 0
      $(document).scrollTop(parseInt($(id).offset().top) - 30)
      @setState(anchorScrolled: true)

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))


  componentWillUnmount: ->
    PostStore.off('change', @refreshStateFromStores)
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
        onStoryClick = { @props.onStoryClick }
        story_id     = { props.story_id }
      />


  render: ->
    posts = @getPosts()
    
    return null if posts.count() == 0 and @props.readOnly
    
    posts = posts.map (post, index) =>
      [
        post
        @renderCreatePostButton('small')
      ]

    <section className="timeline posts">
      { @renderCreatePostButton() }
      { posts.toArray() }
    </section>

# Exports
# 
module.exports = Component
