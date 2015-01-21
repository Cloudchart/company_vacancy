# @cjsx React.DOM

# Imports
# 
tag = React.DOM
cx = React.addons.classSet

GlobalState = require('global_state/state')

PostStore = require('stores/post_store')
BlockStore = require('stores/block_store')
ParagraphStore = require('stores/paragraph_store')
PictureStore = require('stores/picture_store')
VisibilityStore = require('stores/visibility_store')
PersonStore = require('stores/person')
PinStore    = require('stores/pin_store')
PostsStoryStore = require('stores/posts_story_store')

PostActions = require('actions/post_actions')
VisibilityActions = require('actions/visibility_actions')

ModalActions = require('actions/modal_actions')

Post = require('components/post')
ContentEditableArea = require('components/form/contenteditable_area')
PersonAvatar = require('components/shared/person_avatar')

PinFormComponent = require('components/form/pin_form')

FuzzyDate = require('utils/fuzzy_date')


# Main
# 
Component = React.createClass

  
  # Helpers
  # 
  gatherControls: ->
    <ul className="buttons">
      { @getLinkPostWithStoryItem() }
      { @getStarPostForStoryItem() }
      { @getPinPostItem() }
    </ul>

  #     <li className="visibility">
  #       <select value={@state.visibility_value}, onChange={@handleVisibilityChange}>
  #         <option value={'public'}>Public</option>
  #         <option value={'trusted'}>Trusted</option>
  #         <option value={'only_me'}>Only me</option>
  #       </select>
  #     </li>

  #     <li>
  #       <i className="fa fa-times" onClick={@handleDestroyClick} />
  #     </li>

  getPinPostItem: ->
    pins = PinStore.cursor.items.deref(PinStore.empty).filter((item) => item.get('pinnable_type') == 'Post' and item.get('pinnable_id') == @state.post.uuid )

    current_user_pin = pins.find (pin) => pin.get('user_id') == @props.current_user_id
    classes = cx({ active: !!current_user_pin })

    <li onClick={ @handlePinClick.bind(null, current_user_pin) } className={classes}>
      <i className="fa fa-thumb-tack" />
    </li>

  getLinkPostWithStoryItem: ->
    return null unless @props.story_id

    classes = cx
      active: @isRelatedToStory()

    <li onClick={@handleLinkStoryClick} className={classes} >
      <i className="fa fa-link" />
    </li>


  getStarPostForStoryItem: ->
    return null unless @props.story_id

    <li onClick={@handleStarClick}>
      <i className="fa fa-star"></i>
    </li>


  getHeader: ->
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
    </header>


  getFooter: ->
    story_ids = @getStoryIds()

    stories = GlobalState.cursor(['stores', 'stories', 'items']).deref(Immutable.Map())
      .filter (item, key) -> story_ids.contains(key)
      .sortBy (item, key) -> story_ids.indexOf(key)
      .map    @postStoryMapper

    return null if stories.count() == 0

    <footer>
      <div className="cc-hashtag-list">
        <ul>
          {stories.toArray()}
        </ul>
      </div>
    </footer>


  getContent: ->
    first_block = @state.blocks[0]
    return null unless first_block

    first_content_item = @identityContentSwitcher(first_block)

    second_block = @state.blocks[1]
    second_content_item = if second_block and second_block.identity_type isnt first_block.identity_type
      @identityContentSwitcher(second_block)
    else
      null

    <div className="content">
      { first_content_item }
      { second_content_item }
    </div>


  identityContentSwitcher: (block) ->
    switch block.identity_type
      when 'Paragraph' then @getParagraph(block)
      when 'Picture' then @getPicture(block)
      when 'Person' then @getPerson(block)


  postStoryMapper: (story, key) ->
    <li key={key}>
      { '#' + story.get('name') }
    </li>


  getParagraph: (block) ->
    paragraph = ParagraphStore.find (paragraph) -> paragraph.owner_id is block.uuid
    return null unless paragraph

    parts = paragraph.content.match(/<div>(.*?)<\/div>/i)
    content = "<div>#{_.str.truncate(parts[1], 600)}</div>"
    classes = cx
      'paragraph': true
      'quote': block.kind is 'Quote'

    <div className={classes} dangerouslySetInnerHTML={__html: content}></div>


  getPicture: (block) ->
    picture = PictureStore.find (picture) -> picture.owner_id is block.uuid
    return null unless picture

    <img className="cover" src={picture.url}/>


  getPerson: (block) ->
    person = PersonStore.get(block.identity_ids.toJS()[0])
    return null unless person

    <div className="person">
      <PersonAvatar
        value     = {person.full_name}
        avatarURL = {person.avatar_url}
        readOnly  = {true}
      />
      
      <footer>
        <p className="name">{person.full_name}</p>
        <p className="occupation">{person.occupation}</p>
      </footer>
    </div>


  isEpochType: ->
    @state.post.title and @state.post.effective_from and @state.post.effective_till and @state.blocks.length is 0

  isRelatedToStory: ->
    return true unless @props.story_id
    @getStoryIds().contains @props.story_id

  getStoryIds: ->
    PostsStoryStore.cursor.items.deref(Immutable.Map())
      .valueSeq()
      .filter (posts_story) => posts_story.get('post_id') is @state.post.uuid
      .sortBy (posts_story) -> posts_story.get('position')
      .map (posts_story) -> posts_story.get('story_id')


  # Handlers
  #
  
  handlePinClick: (pin, event) ->
    if pin
      PinStore.destroy(pin.get('uuid')) if confirm('Are you sure?')
    else
      ModalActions.show(
        <PinFormComponent pinnable_id={@props.uuid} pinnable_type="Post" title={ @state.post.title } />
      )
    
  
  handleDestroyClick: (event) ->
    event.preventDefault()
    PostActions.destroy(@state.post.uuid) if confirm('Are you sure?')

  handleEditClick: (event) ->
    event.preventDefault()

    scrollTop = document.body.scrollTop
    window.location.hash = @props.uuid
    document.body.scrollTop = scrollTop

  handleVisibilityChange: (event) ->
    value = event.target.value

    if @state.visibility and @state.visibility.value isnt value
      VisibilityActions.update(@state.visibility.uuid, { value: value })
    else
      VisibilityActions.create(VisibilityStore.create(), { owner_id: @props.uuid, value: value })


  handleLinkStoryClick: (event) ->
    console.log 'handleLinkStoryClick'
    # story_ids = if @isRelatedToStory()
    #   @state.post.story_ids.filterNot((id) => id is @props.story_id).toArray()
    # else
    #   @state.post.story_ids.concat(@props.story_id).toArray()

    # PostActions.update(@state.post.uuid, { story_ids: story_ids })


  handleStarClick: (event) ->
    console.log 'handleStarClick'


  # Lifecycle Methods
  # 
  componentDidMount: ->
    BlockStore.on('change', @refreshStateFromStores)
    PersonStore.on('change', @refreshStateFromStores)
    PictureStore.on('change', @refreshStateFromStores)
    ParagraphStore.on('change', @refreshStateFromStores)
    VisibilityStore.on('change', @refreshStateFromStores)

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  componentWillUnmount: ->
    BlockStore.off('change', @refreshStateFromStores)
    PersonStore.off('change', @refreshStateFromStores)
    PictureStore.off('change', @refreshStateFromStores)
    ParagraphStore.off('change', @refreshStateFromStores)
    VisibilityStore.off('change', @refreshStateFromStores)


  # Component Specifications
  # 
  
  
  getDefaultProps: ->
    current_user_id: document.querySelector('meta[name="user-id"]').getAttribute('content')
  
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))


  getStateFromStores: (props) ->
    visibility = VisibilityStore.find (item) -> item.uuid and item.owner_id is props.uuid and item.owner_type is 'Post'
    blocks = _.chain BlockStore.all()
      .filter (block) -> block.owner_id is props.uuid
      .sortBy('position')
      .value()

    post: PostStore.get(props.uuid)
    blocks: blocks
    visibility: visibility
    visibility_value: if visibility then visibility.value else 'public'


  getInitialState: ->
    @getStateFromStores(@props)


  render: ->
    return null unless @state.post

    article_classes = cx
      'preview': true
      'post': true
      'epoch': @isEpochType()
      'dimmed': not @isRelatedToStory()

    <article className={article_classes}>
      { @gatherControls() }

      <a href="" onClick={@handleEditClick}>
        { @getHeader() }
        { @getContent() }
        { @getFooter() }
      </a>
    </article>


# Exports
# 
module.exports = Component
