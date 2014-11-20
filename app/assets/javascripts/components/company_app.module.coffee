# @cjsx React.DOM

# Imports
#
tag = React.DOM

CloudFlux = require('cloud_flux')

CompanyStore    = require('stores/company')
BlockStore      = require('stores/block_store')
PostStore       = require('stores/post_store')
PersonStore     = require('stores/person')

PostActions     = require('actions/post_actions')
ModalActions    = require('actions/modal_actions')

Blockable       = require('components/mixins/blockable')
SortableList    = require('components/shared/sortable_list')
CompanyHeader   = require('components/company/header')
PostPreview     = require('components/company/timeline/post_preview')
PersonPreview   = require('components/company/timeline/person_preview')
Post            = require('components/post')

# Main
#
Component = React.createClass

  mixins: [CloudFlux.mixins.Actions, Blockable]

  # Helpers
  # 
  identityTypes: ->
    People:     'Person'
    Vacancies:  'Vacancy'
    Picture:    'Picture'
    Paragraph:  'Paragraph'

  # TODO: refactor using _.inject without eval
  gatherPosts: ->
    result = []

    # people
    _.each ['hired_on', 'fired_on'], (attribute) =>
      people = _.filter @state.people, (person) -> person.uuid and person[attribute]
      _.each people, (person) -> result.push { date: person[attribute], type: 'Person', data: person.toJSON() }

    # posts
    posts = if @state.readOnly
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
              company_id={@state.company.uuid}
            />
          when 'Person'
            <PersonPreview
              key={index}
              id={object.data.uuid}
              event_type={if object.date == object.data.hired_on then 'hired' else 'fired'}
            />
      .value()
  
  showCreatePostButton: ->
    if @state.readOnly
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
    PostActions.create(new_post_key, { owner_id: @props.id, owner_type: 'Company' })

    @setState({ new_post_key: new_post_key })

  handlePostCreateDone: (id, attributes, json, sync_token) ->
    setTimeout => 
      ModalActions.show(Post({id: json.uuid, company_id: @state.company.uuid, readOnly: @state.readOnly}), class_for_container: 'post')

  handleViewModeChange: (data) ->
    @setState({ readOnly: data.readOnly })

  # Component Specifications
  # 
  getStateFromStores: ->
    company = CompanyStore.get(@props.id)

    blocks: BlockStore.filter (block) => block.owner_type == 'Company' and block.owner_id == @props.id
    posts: PostStore.all()
    people: PersonStore.all()
    company: company
    readOnly: if company then company.flags.is_read_only else true

  refreshStateFromStores: ->
    @setState(@getStateFromStores())
  
  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)
    BlockStore.on('change', @refreshStateFromStores)
    PostStore.on('change', @refreshStateFromStores)
    PersonStore.on('change', @refreshStateFromStores)

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)
    BlockStore.off('change', @refreshStateFromStores)
    PostStore.off('change', @refreshStateFromStores)
    PersonStore.off('change', @refreshStateFromStores)
  
  getInitialState: ->
    state            = @getStateFromStores()
    state.position   = null
    state.owner_type = 'Company'
    state.new_post_key = null
    state

  render: ->
    if @state.company
      blocks = _.map @gatherBlocks(), (block, i) =>
        [
          @getSectionPlaceholder(i)
          block
        ]

      <div className="wrapper">
        <CompanyHeader
          key             = {@props.id}
          name            = {@state.company.name}
          description     = {@state.company.description}
          logotype_url    = {@state.company.logotype_url}
          readOnly        = {@state.readOnly}
          can_follow      = {@state.company.flags.can_follow}
          is_followed     = {@state.company.flags.is_followed}
          invitable_roles = {@state.company.meta.invitable_roles}
          onChange        = {@handleViewModeChange}
          shouldDisplayViewMode = {if @state.company.flags.is_read_only then false else true}
        />
        
        <SortableList
          component={tag.article}
          className="editor company company-2_0"
          onOrderChange={@handleSortableChange}
          onOrderUpdate={@handleSortableUpdate}
          readOnly={@state.readOnly}
          dragLockX
        >
          {blocks}
          {@getSectionPlaceholder(blocks.length)}
        </SortableList>

        <div className="posts">
          {@showCreatePostButton()}
          {@gatherPosts()}
          <div className="timeline"></div>
        </div>
      </div>

    else
      null

# Exports
#
module.exports = Component
