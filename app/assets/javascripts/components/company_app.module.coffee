# @cjsx React.DOM

# Imports
#
tag = React.DOM

Blockable = require('components/mixins/blockable')

CompanyStore    = require('stores/company')
BlockStore      = require('stores/block_store')
PostStore       = require('stores/post_store')

PostActions     = require('actions/post_actions')

SortableList    = require('components/shared/sortable_list')
CompanyHeader   = require('components/company/header')
PostPreview     = require('components/post_preview')

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
    _.chain @state.posts
      .filter('uuid')
      .sortBy (post) -> new Date(post.published_at)
      .reverse()
      .map (post) => <PostPreview key={post.uuid} id={post.uuid}, company_id={@state.company.uuid}, readOnly={@state.company.flags.is_read_only} />
      .value()
  
  showCreatePostButton: ->
    if @state.company.flags.is_read_only
      null
    else
      <button className="cc" onClick={@handleCreatePostClick}>Create Post</button>

  # Handlers
  # 
  handleCreatePostClick: (event) ->
    newPostKey = PostStore.create()
    PostActions.create(newPostKey, { owner_id: @props.id, owner_type: 'Company' })

  # Component Specifications
  # 
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
        {@showCreatePostButton()}
        
        <div className="posts">
          {@gatherPosts()}
          <div className="timeline"></div>
        </div>
      </div>

    else
      null

# Exports
#
module.exports = Component
