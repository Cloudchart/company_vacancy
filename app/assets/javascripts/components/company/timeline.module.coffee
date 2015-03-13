# @cjsx React.DOM

# Imports
# 
tag = React.DOM

CloudFlux = require('cloud_flux')
GlobalState = require('global_state/state')

PostStore = require('stores/post_store')
PinStore  = require('stores/pin_store')
StoryStore = require('stores/story_store')
PostsStoryStore = require('stores/posts_story_store')

PostActions = require('actions/post_actions')

PostPreview = require('components/company/timeline/post_preview')
Post = require('components/post')


# Utils
#
postVisibilityPredicate = (post) ->
  post.uuid and post.created_at != post.updated_at


# Main
# 
Component = React.createClass

  mixins: [CloudFlux.mixins.Actions, GlobalState.mixin]

  # Component Specifications
  # 
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
    state               = @getStateFromStores(@props)
    state.new_post_key  = null
    state

  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    posts:      PostStore.all()
    postSeq:    Immutable.Seq(PostStore.all())


  # Helpers
  #
  getCreatePostButton: (type = '') ->
    return null if @props.readOnly
      
    class_for_icon =
      if PostStore.getSync(@state.new_post_key) == "create"
        'fa fa-spin fa-spinner'
      else
        'cc-icon cc-plus'

    if type == 'placeholder'
      <div className="placeholder">
        <figure className={type} onClick={@handleCreatePostClick} >
          <i className={class_for_icon}></i>
        </figure>
      </div>
    else
      <figure className="create" onClick={@handleCreatePostClick}>
        <i className={class_for_icon}></i>
      </figure>


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


  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))


  componentWillUnmount: ->
    PostStore.off('change', @refreshStateFromStores)


  # Renderers
  #
  renderPosts: ->
    @state.postSeq
      .filter postVisibilityPredicate
      .sortBy (post) -> post.effective_from
      .map    @renderPost(@props)
      .reverse()

  renderPost: (props) ->
    (post) =>
      <PostPreview
        key          = { post.uuid }
        uuid         = { post.uuid }
        company_id   = { props.company_id }
        onStoryClick = { @props.onStoryClick }
        story_id     = { props.story_id }
        readOnly     = { props.readOnly }
      />


  render: ->
    posts = @renderPosts()
    
    return null if posts.count() == 0 and @props.readOnly
    
    posts = posts.map (post, index) =>
      [
        post
        @getCreatePostButton('placeholder')
      ]

    <div className="posts">
      { @getCreatePostButton() }
      { posts.toArray() }
    </div>

# Exports
# 
module.exports = Component
