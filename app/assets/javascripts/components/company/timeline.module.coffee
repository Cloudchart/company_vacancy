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
ModalActions = require('actions/modal_actions')

PostPreview = require('components/company/timeline/post_preview')
Post = require('components/post')

UUID = require('utils/uuid')

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

    # Dirty hack here, need to fix later

    if type == 'placeholder'
      <div className="placeholder">
        <a href="/companies/#{@props.company_id}/posts/new" className="for-group">
          <figure className={type}>
            <i className={class_for_icon}></i>
          </figure>
        </a>
      </div>
    else
      <a href="/companies/#{@props.company_id}/posts/new" className="for-group">
        <figure className="create">
          <i className={class_for_icon}></i>
        </figure>
      </a>

  getCloudFluxActions: ->
    'post:create:done': @handlePostCreateDone

  showPostInModal: (id) ->
    return unless @state.postSeq.map((post) -> post.uuid).contains(id)
    
    setTimeout => 
      ModalActions.show(
        <Post id={id} company_id={@props.company_id} cursor={Post.getCursor(@props.company_id)} readOnly={@props.readOnly} />,
        class_for_container: 'post'
        beforeHide: ->
          scrollTop = document.body.scrollTop
          window.location.hash = ''
          document.body.scrollTop = scrollTop
      )

  # Handlers
  #
  handlePostCreateDone: (id, attributes, json, sync_token) ->
    @showPostInModal(json.uuid)
  
  
  handleWindowHashChange: (event) ->
    postId = window.location.hash.split('#').pop()
    @showPostInModal(postId) if UUID.isUUID(postId)



  # Lifecycle Methods
  # 
  onGlobalStateChange: ->
    @setState
      refreshed_at: + new Date


  componentDidMount: ->
    PostStore.on('change', @refreshStateFromStores)
    window.addEventListener('hashchange', @handleWindowHashChange)

    setTimeout =>
      @handleWindowHashChange()
    , 100


  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))


  componentWillUnmount: ->
    PostStore.off('change', @refreshStateFromStores)
    window.removeEventListener('hashchange', @handleWindowHashChange)


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
