# @cjsx React.DOM

# Imports
#
tag = React.DOM

Blockable = require('components/mixins/blockable')

CompanyStore    = require('stores/company')
BlockStore      = require('stores/block_store')
PostStore       = require('stores/post_store')

ModalActions    = require('actions/modal_actions')
PostActions     = require('actions/post_actions')

SortableList    = require('components/shared/sortable_list')
CompanyHeader   = require('components/company/header')
Post            = require('components/post')
PostForm        = require('components/form/post_form')

# Main
#
Component = React.createClass

  mixins: [Blockable]

  # Helpers
  # 
  identityTypes: ->
    People:     'Person'
    Vacancies:  'Vacancy'
    Picture:    'Picture'
    Paragraph:  'Paragraph'


  gatherPosts: ->
    if @state.posts.length > 0
      _.map @state.posts, (post) =>
        <Post key={post.uuid} id={post.uuid}, company_id={@props.id} />


  # Handlers
  # 
  handleNewPostClick: (event) ->
    event.preventDefault()
    newPostKey = PostStore.create({ owner_id: @props.id, owner_type: 'Company' })

    ModalActions.show(PostForm({
      attributes: PostStore.get(newPostKey).toJSON()
      onSubmit:   @handlePostFormSubmit.bind(@, newPostKey)
    }))


  handlePostFormSubmit: (key, attributes) ->
    post = PostStore.get(key)
    if post.uuid
      # to be implemented
      # PostActions.update(key, attributes.toJSON())
    else
      PostActions.create(key, attributes.toJSON())
      ModalActions.hide()


  getStateFromStores: ->
    company: CompanyStore.get(@props.id)
    blocks: BlockStore.filter (block) => block.owner_type == 'Company' and block.owner_id == @props.id
    posts: PostStore.all()
  
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores())
  
  
  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)
    BlockStore.on('change', @refreshStateFromStores)
    PostStore.on('change', @refreshStateFromStores)
  

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)
    BlockStore.off('change', @refreshStateFromStores)
    PostStore.off('change', @refreshStateFromStores)
  
  
  getInitialState: ->
    state            = @getStateFromStores()
    state.position   = null
    state.owner_type = 'Company'
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
          readOnly        = {@state.company.flags.is_read_only}
          can_follow      = {@state.company.flags.can_follow}
          is_followed     = {@state.company.flags.is_followed}
          invitable_roles = {@state.company.meta.invitable_roles}
        />
        
        <SortableList
          component={tag.article}
          className="editor company company-2_0"
          onOrderChange={@handleSortableChange}
          onOrderUpdate={@handleSortableUpdate}
          readOnly={@state.company.flags.is_read_only}
          dragLockX
        >
          {blocks}
          {@getSectionPlaceholder(blocks.length)}
        </SortableList>

        <div className="separator"></div>

        <a href="" onClick={@handleNewPostClick}>New Post</a>

        {@gatherPosts()}
      </div>

    else
      null


# Exports
#
module.exports = Component
