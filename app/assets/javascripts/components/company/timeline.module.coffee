# @cjsx React.DOM

# Imports
# 
tag = React.DOM

CloudFlux = require('cloud_flux')

PostStore = require('stores/post_store')

PostActions  = require('actions/post_actions')
ModalActions = require('actions/modal_actions')

PostPreview = require('components/company/timeline/post_preview')
Post        = require('components/post')


# Utils
#

postPreviewMapper = (props) ->
  (post) ->
    <PostPreview
      key         = { post.uuid }
      id          = { post.uuid }
      company_id  = { props.company_id }
      readOnly    = { props.read_only }
    />


postVisibilityPredicate = (post) ->
  post.uuid and post.created_at != post.updated_at


# Main
# 
Component = React.createClass

  mixins: [CloudFlux.mixins.Actions]


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
    setTimeout => 
      ModalActions.show(
        <Post id={id} company_id={@props.company_id} readOnly={@props.readOnly} />,
        class_for_container: 'post'
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


  # Lifecycle Methods
  # 
  # componentWillMount: ->


  componentDidMount: ->
    PostStore.on('change', @refreshStateFromStores)


  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))


  componentWillUnmount: ->
    PostStore.off('change', @refreshStateFromStores)

  # Component Specifications
  # 
  # getDefaultProps: ->

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
