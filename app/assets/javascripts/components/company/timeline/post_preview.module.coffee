# @cjsx React.DOM

# Imports
#
cx = React.addons.classSet

GlobalState         = require('global_state/state')

PostStore           = require('stores/post_store')
BlockStore          = require('stores/block_store')
ParagraphStore      = require('stores/paragraph_store')
PictureStore        = require('stores/picture_store')
PersonStore         = require('stores/person')
PostsStoryStore     = require('stores/posts_story_store')
UserStore           = require('stores/user_store.cursor')
VisibilityStore     = require('stores/visibility_store')

QuoteStore          = require('stores/quote_store')

PostActions         = require('actions/post_actions')

Post                = require('components/post')
Tags                = require('components/company/tags')
ContentEditableArea = require('components/form/contenteditable_area')
PersonAvatar        = require('components/shared/person_avatar')
Avatar              = require('components/avatar')

InsightListComponent = require('components/insight/list')

PinButton           = require('components/pinnable/pin_button')

FuzzyDate           = require('utils/fuzzy_date')


# Main
#
Component = React.createClass

  mixins: [GlobalState.mixin]

  # Helpers
  #
  identityContentSwitcher: (block) ->
    switch block.identity_type
      when 'Paragraph' then @getParagraph(block)
      when 'Picture' then @getPicture(block)
      when 'Person' then @getBlockPerson(block)
      when 'Quote' then @getQuote(block)


  postStoryMapper: (story, key) ->
    <li key={key}>
      { '#' + story.get('formatted_name') }
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

  getBlockPerson: (block) ->
    person_id = block.identity_ids.toJS()[0]
    return null unless person_id

    @getPerson(person_id)

  getPerson: (person_id) ->
    return null unless person_id
    person = PersonStore.get(person_id)

    <div className="person">
      <PersonAvatar
        value     = { person.full_name }
        avatarURL = { person.avatar_url }
        readOnly  = { true }
      />

      <footer>
        <p className="name">{person.full_name}</p>
        <p className="occupation">{person.occupation}</p>
      </footer>
    </div>

  getQuote: (block) ->
    quote = QuoteStore.findByBlock(block.get("uuid"))
    return null unless quote

    <div className="quote">
      { @getPerson(quote.get("person_id")) }
      
      <div dangerouslySetInnerHTML={__html: quote.get("text")}></div>
    </div>

  isEpochType: ->
    @state.post.title and @state.post.effective_from and @state.post.effective_till and @state.blocks.length is 0

  isOnlyMeVisibility: ->
    @state.visibility && @state.visibility.value == "only_me"

  isRelatedToStory: ->
    return true unless @props.story_id
    @getStoryIds().contains @props.story_id

  getStoryIds: ->
    PostsStoryStore.cursor.items.deref(Immutable.Map())
      .valueSeq()
      .filter (posts_story) => posts_story.get('post_id') is @state.post.uuid
      .map (posts_story) -> posts_story.get('story_id')


  # Handlers
  #
  handleEditClick: (event) ->
    event.preventDefault()

    scrollTop = document.body.scrollTop
    window.location.hash = @props.uuid
    document.body.scrollTop = scrollTop

  handleLinkStoryClick: (event) ->
    if @isRelatedToStory()
      id = PostsStoryStore.findByPostAndStoryIds(@props.uuid, @props.story_id).get('uuid')
      PostsStoryStore.destroy(id)
    else
      PostsStoryStore.create(@props.uuid, { story_id: @props.story_id })


  handleStarClick: (posts_story, event) ->
    is_highlighted = if posts_story.get('is_highlighted') then false else true
    PostsStoryStore.update(posts_story.get('uuid'), { is_highlighted: is_highlighted }, { optimistic: false })


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
    cursor:
      quotes: QuoteStore.cursor.items
    current_user_id: document.querySelector('meta[name="user-id"]').getAttribute('content')

  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    blocks = _.chain BlockStore.all()
      .filter (block) -> block.owner_id is props.uuid
      .sortBy('position')
      .value()

    post: PostStore.get(props.uuid)
    blocks: blocks
    visibility: VisibilityStore.find (item) -> item.uuid && item.owner_id is props.uuid && item.owner_type is 'Post'

  getInitialState: ->
    @getStateFromStores(@props)

  onGlobalStateChange: ->
    @setState @getStateFromStores(@props)

  # Renderers
  #
  renderInsights: ->
    <InsightListComponent pinnable_id={ @props.uuid } pinnable_type="Post" />


  renderPinPostItem: ->
    <PinButton pinnable_type='Post' pinnable_id={ @state.post.uuid } title={ @state.post.title } />


  renderControls: ->
    <ul className="buttons round-buttons">
      { @renderLinkPostWithStoryItem() }
      { @renderStarPostForStoryItem() }
      { @renderPinPostItem() }
    </ul>

  renderOnlyMeOverlay: ->
    return null unless @isOnlyMeVisibility()

    <div className="only-me-overlay" onClick={@handleEditClick}>
      <i className="fa fa-lock"></i>
    </div>

  renderLinkPostWithStoryItem: ->
    return null unless @props.story_id

    classes = cx
      active: @isRelatedToStory()

    <li onClick={@handleLinkStoryClick} className={classes} >
      <i className="fa fa-link" />
    </li>


  renderStarPostForStoryItem: ->
    return null unless @props.story_id
    posts_story = PostsStoryStore.findByPostAndStoryIds(@props.uuid, @props.story_id)
    return null unless posts_story

    classes = cx
      active: posts_story.get('is_highlighted')

    iconClassList = cx
      fa: true
      'fa-star': !posts_story.get('--sync--')
      'fa-spin fa-spinner': posts_story.get('--sync--')

    <li onClick={@handleStarClick.bind(@, posts_story)} className={classes} >
      <i className={iconClassList}></i>
    </li>

  renderHeader: ->
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

  renderStories: ->
    story_ids = @getStoryIds()

    stories = GlobalState.cursor(['stores', 'stories', 'items']).deref(Immutable.Map())
      .filter (item, key) -> story_ids.contains(key)
      .sortBy (item, key) -> item.get('name')
      .map    @postStoryMapper

    return null if stories.count() == 0

    <div className="cc-hashtag-list">
      <ul>
        {stories.toArray()}
      </ul>
    </div>

  renderContent: ->
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

  renderFooter: ->
    <footer>
      { @renderStories() }
    </footer>

  render: ->
    return null unless @state.post

    article_classes = cx
      'preview': true
      'post': true
      'epoch': @isEpochType()
      'only-me': @isOnlyMeVisibility()
      'dimmed': not @isRelatedToStory()

    <article className={article_classes}>
      { @renderControls() }
      { @renderInsights() }

      { @renderOnlyMeOverlay() }

      <a href="" onClick={@handleEditClick}>
        { @renderHeader() }
        { @renderContent() }
        { @renderFooter() }
      </a>

    </article>


# Exports
#
module.exports = Component
