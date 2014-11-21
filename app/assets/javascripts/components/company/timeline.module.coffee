# @cjsx React.DOM

# Imports
# 
tag = React.DOM

CloudFlux = require('cloud_flux')

# CompanyStore = require('stores/company')
PostStore = require('stores/post_store')
PersonStore = require('stores/person')

PostActions  = require('actions/post_actions')
ModalActions = require('actions/modal_actions')

PostPreview = require('components/company/timeline/post_preview')
PersonPreview = require('components/company/timeline/person_preview')
Post = require('components/post')

# Main
# 
Component = React.createClass

  mixins: [CloudFlux.mixins.Actions]

  # Helpers
  # 
  # TODO: refactor using _.inject without eval
  gatherPosts: ->
    result = []

    # people
    _.each ['hired_on', 'fired_on'], (attribute) =>
      people = _.filter @state.people, (person) -> person.uuid and person[attribute]
      _.each people, (person) -> result.push { date: person[attribute], type: 'Person', data: person.toJSON() }

    # posts
    posts = if @props.readOnly
      _.filter @state.posts, (post) -> post.uuid and post.published_at
    else
      _.filter @state.posts, 'uuid'

    _.each posts, (post) -> result.push { date: post.published_at, type: 'Post', data: post.toJSON() }
    
    # result
    _.chain result
      .sortBy (object) -> new Date(object.date)
      .reverse()
      .map (object, index) =>
        switch object.type
          when 'Post'
            <PostPreview
              key={index}
              id={object.data.uuid}
              company_id={@props.company_id}
              readOnly={@props.readOnly}
            />
          when 'Person'
            <PersonPreview
              key={index}
              id={object.data.uuid}
              event_type={if object.date == object.data.hired_on then 'hired' else 'fired'}
              readOnly={@props.readOnly}
            />
      .value()
  
  showCreatePostButton: ->
    if @props.readOnly
      null
    else
      class_for_icon =
        if PostStore.getSync(@state.new_post_key) == "create"
          'fa fa-spin fa-spinner'
        else
          'fa fa-plus'

      <figure className="create" onClick={@handleCreatePostClick}>
        <i className={class_for_icon}></i>
      </figure>

  getCloudFluxActions: ->
    'post:create:done': @handlePostCreateDone

  # Handlers
  # 
  handleCreatePostClick: (event) ->
    new_post_key = PostStore.create()
    PostActions.create(new_post_key, { owner_id: @props.company_id, owner_type: 'Company' })

    @setState({ new_post_key: new_post_key })

  handlePostCreateDone: (id, attributes, json, sync_token) ->
    setTimeout => 
      ModalActions.show(Post({id: json.uuid, company_id: @props.company_id, readOnly: @props.readOnly}), class_for_container: 'post')

  # Lifecycle Methods
  # 
  # componentWillMount: ->

  componentDidMount: ->
    PostStore.on('change', @refreshStateFromStores)
    PersonStore.on('change', @refreshStateFromStores)

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->

  componentWillUnmount: ->
    PostStore.off('change', @refreshStateFromStores)
    PersonStore.off('change', @refreshStateFromStores)

  # Component Specifications
  # 
  # getDefaultProps: ->

  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    posts: PostStore.all()
    people: PersonStore.all()

  getInitialState: ->
    state = @getStateFromStores(@props)
    state.new_post_key = null
    state

  render: ->
    <div className="posts">
      {@showCreatePostButton()}
      {@gatherPosts()}
      <div className="timeline"></div>
    </div>    

# Exports
# 
module.exports = Component
