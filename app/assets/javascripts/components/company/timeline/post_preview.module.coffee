# @cjsx React.DOM

# Imports
# 
tag = React.DOM

GlobalState = require('global_state/state')

PostStore = require('stores/post_store')
BlockStore = require('stores/block_store')
ParagraphStore = require('stores/paragraph_store')
PictureStore = require('stores/picture_store')
VisibilityStore = require('stores/visibility_store')

PostActions = require('actions/post_actions')
ModalActions = require('actions/modal_actions')
VisibilityActions = require('actions/visibility_actions')

Post = require('components/post')
ContentEditableArea = require('components/form/contenteditable_area')


FuzzyDate = require('utils/fuzzy_date')


# Main
# 
Component = React.createClass

  # Helpers
  # 
  gatherControls: ->
    return null if @props.readOnly

    <ul className="controls">
      <li className="visibility">
        <select value={@state.visibility_value}, onChange={@handleVisibilityChange}>
          <option value={'public'}>Public</option>
          <option value={'trusted'}>Trusted</option>
          <option value={'only_me'}>Only me</option>
        </select>
      </li>
      <li>
        <i className="fa fa-times" onClick={@handleDestroyClick}></i>
      </li>
    </ul>

  getFirstParagraph: ->
    block = @getBlocksByIdentity('Paragraph')[0]
    paragraph =
      if block
        _.chain @state.paragraphs
          .filter (paragraph) -> paragraph.owner_id == block.uuid
          .first()
          .value()
      else
        null

    if paragraph and paragraph.content
      parts = paragraph.content.match(/<div>(.*?)<\/div>/i)
      content = "<div>#{_.str.truncate(parts[1], 600)}</div>"

      <div className="paragraph" dangerouslySetInnerHTML={__html: content}></div>
    else
      ''

  # left only cover for now
  gatherPictures: ->
    block_ids = _.pluck @getBlocksByIdentity('Picture'), 'uuid'
    # pictures = _.filter @state.pictures, (picture) -> _.contains block_ids, picture.owner_id
    pictures = _.filter @state.pictures, (picture) -> picture.owner_id is block_ids[0]

    # if pictures.length is 1
    if pictures.length > 0
      <img className="cover" src={pictures[0].url}/>
    # else if pictures.length > 1
    #   <ul className="pictures">
    #     {
    #       _.map pictures, (picture) -> 
    #         <li key={picture.uuid} style={'background-image': "url(#{picture.url})"}></li>
    #     }
    #   </ul>
    else
      null

  getBlocksByIdentity: (identity_type) ->
    _.chain BlockStore.all()
      .filter (block) => block.owner_id is @props.id and block.identity_type is identity_type
      .sortBy('position')
      .value()


  postStoryMapper: (story, key) ->
    <li key={key}>
      { '#' + story.get('name') }
    </li>


  gatherStories: ->
    Stories   = GlobalState.cursor(['stores', 'stories', 'items']).deref()

    return null unless Stories
    
    postStoryIds  = Immutable.Seq(@state.post.story_ids)

    stories = Stories
      .filter (item, key) -> postStoryIds.contains(key)
      .sortBy (item, key) -> postStoryIds.indexOf(key)
      .map    @postStoryMapper

    return null if stories.count() == 0

    <div className="cc-hashtag-list">
      <ul>
        {stories.toArray()}
      </ul>
    </div>

  getHeader: ->
    # formatted_date = if moment(@state.post.published_at || null).isValid()
    #   moment(@state.post.published_at).format('ll')
    # else ''
    
    formatted_date = FuzzyDate.format(@state.post.effective_from, @state.post.effective_till)
      
    title = if @state.post.title
      <h1 dangerouslySetInnerHTML = { __html: @state.post.title } />
    else
      <h1>{formatted_date}</h1>

    date = if @state.post.title
      <span className="date">{formatted_date}</span>
    else null
      
    <header>
      {title}
      {date}
      {@gatherStories()}
    </header>

  # Handlers
  # 
  handleDestroyClick: (event) ->
    event.preventDefault()
    PostActions.destroy(@state.post.uuid) if confirm('Are you sure?')

  handleEditClick: (event) ->
    event.preventDefault()
    # ModalActions.show(Post({
    #   id: @props.id
    #   company_id: @props.company_id
    #   readOnly: @props.readOnly
    # }), class_for_container: 'post')
    scrollTop = document.body.scrollTop
    window.location.hash = @props.id
    document.body.scrollTop = scrollTop

  handleVisibilityChange: (event) ->
    value = event.target.value

    if @state.visibility and @state.visibility.value isnt value
      VisibilityActions.update(@state.visibility.uuid, { value: value })
    else
      VisibilityActions.create(VisibilityStore.create(), { owner_id: @props.id, value: value })

  # Lifecycle Methods
  # 
  # componentWillMount: ->

  componentDidMount: ->
    ParagraphStore.on('change', @refreshStateFromStores)
    PictureStore.on('change', @refreshStateFromStores)
    VisibilityStore.on('change', @refreshStateFromStores)

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->

  componentWillUnmount: ->
    ParagraphStore.off('change', @refreshStateFromStores)
    PictureStore.off('change', @refreshStateFromStores)
    VisibilityStore.off('change', @refreshStateFromStores)

  # Component Specifications
  # 
  # getDefaultProps: ->

  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    visibility = VisibilityStore.find (item) -> item.uuid and item.owner_id is props.id and item.owner_type is 'Post'

    post: PostStore.get(props.id)
    paragraphs: ParagraphStore.all()
    pictures: PictureStore.all()
    visibility: visibility
    visibility_value: if visibility then visibility.value else 'public'

  getInitialState: ->
    @getStateFromStores(@props)

  render: ->
    return null unless @state.post

    <article className="preview post">
      {@gatherControls()}

      <a href="" onClick={@handleEditClick}>
        {@getHeader()}
        {@getFirstParagraph()}
        {@gatherPictures()}
      </a>
    </article>

# Exports
# 
module.exports = Component
