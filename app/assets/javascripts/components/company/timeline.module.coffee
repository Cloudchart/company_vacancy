# @cjsx React.DOM

# Imports
# 
tag = React.DOM

CloudFlux = require('cloud_flux')
GlobalState = require('global_state/state')

PostStore = require('stores/post_store')
PinStore  = require('stores/pin_store')

PostActions = require('actions/post_actions')
ModalActions = require('actions/modal_actions')

PostPreview = require('components/company/timeline/post_preview')
Post = require('components/post')

UUID = require('utils/uuid')

# Utils
#
postPreviewMapper = (props) ->
  (post) ->
    <PostPreview
      key         = { post.uuid }
      uuid        = { post.uuid }
      company_id  = { props.company_id }
      readOnly    = { props.readOnly }
      pins        = { props.cursor.pins.deref(PinStore.empty).filter((item) -> item.get('pinnable_type') == 'Post' and item.get('pinnable_id') == post.uuid ) }
    />


postVisibilityPredicate = (post) ->
  post.uuid and post.created_at != post.updated_at


# Main
# 
Component = React.createClass

  mixins: [CloudFlux.mixins.Actions, GlobalState.mixin]


  gatherPosts: ->
    @state.postSeq
      .filter postVisibilityPredicate
      .sortBy (post) -> post.effective_from
      .map    postPreviewMapper(@props)
      .reverse()
  

  getCreatePostButton: (type = '') ->
    return null if @props.readOnly
      
    class_for_icon =
      if PostStore.getSync(@state.new_post_key) == "create"
        'fa fa-spin fa-spinner'
      else
        'cc-icon cc-plus'

    if type == 'placeholder'
      <div className="placeholder">
        <figure className={type} onClick={@handleCreatePostClick}>
          <i className={class_for_icon}></i>
        </figure>
      </div>
    else
      <figure className="create" onClick={@handleCreatePostClick}>
        <i className={class_for_icon}></i>
      </figure>

  getCloudFluxActions: ->
    'post:create:done': @handlePostCreateDone

  showPostInModal: (id) ->
    return unless @state.postSeq.map((post) -> post.uuid).contains(id)
    
    setTimeout => 
      ModalActions.show(
        <Post id={id} company_id={@props.company_id} readOnly={@props.readOnly} />,
        class_for_container: 'post'
        beforeHide: ->
          scrollTop = document.body.scrollTop
          window.location.hash = ''
          document.body.scrollTop = scrollTop
      )

  # Handlers
  # 
  handleCreatePostClick: (event) ->
    return if PostStore.getSync(@state.new_post_key) == "create"

    if post = _.find(@state.posts, (post) -> post.uuid and post.created_at == post.updated_at)
      @showPostInModal(post.uuid)
    else
      new_post_key = PostStore.create()
      PostActions.create(new_post_key, { owner_id: @props.company_id, owner_type: 'Company' })

      @setState({ new_post_key: new_post_key })


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
    @handleWindowHashChange()


  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))


  componentWillUnmount: ->
    PostStore.off('change', @refreshStateFromStores)
    window.removeEventListener('hashchange', @handleWindowHashChange)


  # Component Specifications
  # 
  
  getDefaultProps: ->
    cursor:
      pins: PinStore.cursor.items


  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    posts:      PostStore.all()
    postSeq:    Immutable.Seq(PostStore.all())

  getInitialState: ->
    state               = @getStateFromStores(@props)
    state.new_post_key  = null
    state

  render: ->
    posts = @gatherPosts()
    
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
