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
PinStore            = require('stores/pin_store')
UserStore           = require('stores/user_store.cursor')
VisibilityStore     = require('stores/visibility_store')
QuoteStore          = require('stores/quote_store')

PostActions         = require('actions/post_actions')

Post                = require('components/post')
ContentEditableArea = require('components/form/contenteditable_area')
PersonAvatar        = require('components/shared/person_avatar')
Avatar              = require('components/avatar')

InsightTimelineList = require('components/insight/timeline_list')

PinButton           = require('components/pinnable/pin_button')

FuzzyDate           = require('utils/fuzzy_date')


# Main
#
Component = React.createClass

  displayName: "TimelinePostPreview"

  propTypes:
    story:         React.PropTypes.object
    readOnly:      React.PropTypes.bool.isRequired
    uuid:          React.PropTypes.string.isRequired

  mixins: [GlobalState.mixin]

  # Component Specifications
  #
  getDefaultProps: ->
    cursor:
      pins: PinStore.cursor.items
      quotes: QuoteStore.cursor.items
    current_user_id: document.querySelector('meta[name="user-id"]').getAttribute('content')

  getStateFromStores: (props) ->
    blocks = _.chain BlockStore.all()
      .filter (block) -> block.owner_id is props.uuid
      .sortBy('position')
      .value()

    post: PostStore.get(props.uuid)
    blocks: blocks
    visibility: VisibilityStore.find (item) -> item.uuid && item.owner_id is props.uuid && item.owner_type is 'Post'

  getInitialState: ->
    _.extend @getStateFromStores(@props),
      asPlaceholder: true

  onGlobalStateChange: ->
    @setState refreshed_at: + new Date


  # Helpers
  #
  identityContentSwitcher: (block) ->
    switch block.identity_type
      when 'Paragraph' then @getParagraph(block)
      when 'Picture' then @getPicture(block)
      when 'Person' then @getBlockPerson(block)
      when 'Quote' then @getQuote(block)

  getStoryView: (story) ->
    storyContent = '#' + story.get('formatted_name')

    if story.get('company_id') then storyContent else <strong>{ storyContent }</strong>

  postStoryMapper: (story, key) ->
    isCurrentStory = if @props.story then story.get('uuid') is @props.story.get('uuid') else false

    <li key={key} className={ cx(current: isCurrentStory) } onClick={ @handleStoryClick.bind(@, story) }>
      { @getStoryView(story) }
    </li>

  isBlockTruncated: (block) ->
    return false if block.identity_type != 'Paragraph'
    return false unless (paragraph = @getParagraphByBlock(block))

    @getTruncatedParagraph(block) != paragraph.content

  getParagraphByBlock: (block) ->
    ParagraphStore.find (paragraph) -> paragraph.owner_id is block.uuid

  getTruncatedParagraph: (block) ->
    return null unless (paragraph = @getParagraphByBlock(block))

    parts = paragraph.content.match(/<div>(.*?)<\/div>/i)

    "<div>#{parts[1]}</div>"

  getParagraph: (block) ->
    content = @getTruncatedParagraph(block)

    classes = cx
      'paragraph': true
      'quote': block.kind is 'Quote'

    <div className={classes} dangerouslySetInnerHTML={__html: content}></div>

  getPicture: (block) ->
    picture = PictureStore.find (picture) -> picture.owner_id is block.uuid
    return null unless picture

    <img className={ "cover #{picture.size}" } src={picture.url}/>

  getBlockPerson: (block) ->
    person_id = block.identity_ids.toJS()[0]
    return null unless person_id

    <div className="person-list">
      <div className="row">
        <div className="item">
          { @getPerson(person_id) }
        </div>
      </div>
    </div>

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
      <div className="quote-wrapper">
        { @getPerson(quote.get("person_id")) }
        
        <div className="quote-text" dangerouslySetInnerHTML={__html: quote.get("text")}></div>
      </div>
    </div>

  isEpochType: ->
    @state.post.title and @state.post.effective_from and @state.post.effective_till and @state.blocks.length is 0

  isOnlyMeVisibility: ->
    @state.visibility && @state.visibility.value == "only_me"

  isRelatedToStory: ->
    return true unless @props.story
    @getStoryIds().contains @props.story.get('uuid')

  isQuote: ->
    @state.blocks.length == 1 && @state.blocks[0].identity_type == "Quote"

  getStoryIds: ->
    @state.post.story_ids

  getInsightsNumber: ->
    PinStore.filterInsightsForPost(@props.uuid).size


  # temp and hacky solution to display updates
  updateStoryIds: (action) ->
    story_ids = switch action
      when 'link'
        @state.post.story_ids.concat(@props.story.get('uuid'))
      when 'unlink'
        @state.post.story_ids.filterNot((id) => id is @props.story.get('uuid'))
    
    PostStore.update(@state.post.uuid, story_ids: story_ids.toArray())
    PostStore.emitChange()


  isLoaded: ->
    @state.post

  handleScroll: (event) ->
    if @timer || @stickyTimer
      clearTimeout @timer
      clearTimeout @stickyTimer

    newScroll = $(window).scrollTop()
    direction = if newScroll - @lastScroll > 0 then 'down' else 'up'
    @lastScroll = newScroll

    @timer       = setTimeout @changePlaceholder.bind(@, direction), 100
    @stickyTimer = setTimeout @scrollSticky, 1000

  changePlaceholder: (direction=null) ->
    return unless @isMounted()

    difference = $(@getDOMNode()).offset().top - $(window).scrollTop()
    bottomBorder = if direction == 'down' then 3 * $(window).height() else $(window).height()

    if difference > 0 && difference < bottomBorder
      @setState asPlaceholder: false

  scrollSticky: ->
    return unless @isMounted()
    
    headerHeight = $('body > header').height()
    difference = $(window).scrollTop() - $(@getDOMNode()).offset().top

    if difference < $(@getDOMNode()).height() && difference > 10 && @state.asPlaceholder
      $('html,body').animate({ scrollTop: $(@getDOMNode()).next().offset().top - (10 + headerHeight) }, 'slow')


  # Handlers
  #
  handleLinkStoryClick: (event) ->
    if @isRelatedToStory()
      id = PostsStoryStore.findByPostAndStoryIds(@props.uuid, @props.story.get('uuid')).get('uuid')
      PostsStoryStore.destroy(id)
      @updateStoryIds('unlink')
    else
      PostsStoryStore.create(@props.uuid, { story_id: @props.story.get('uuid') })
      @updateStoryIds('link')

  handleStarClick: (posts_story, event) ->
    is_highlighted = if posts_story.get('is_highlighted') then false else true
    PostsStoryStore.update(posts_story.get('uuid'), { is_highlighted: is_highlighted }, { optimistic: false })

  handleStoryClick: (story) ->  
    event.preventDefault()
    event.stopPropagation()
    $('html,body').animate({ scrollTop: $(".timeline").offset().top - 30 }, 'slow')

    if @props.story is null or @props.story.get('uuid') != story.get('uuid')
      location.hash = "story-#{story.get('name')}"


  # Lifecycle Methods
  #
  componentDidMount: ->
    @lastScroll = $(window).scrollTop()
    @timer = false
    @stickyTimer = false

    @timer = setTimeout @changePlaceholder, 1000
    @stickyTimer = setTimeout @scrollSticky, 1000
    window.addEventListener "scroll", @handleScroll
    window.addEventListener "resize", @changePlaceholder

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  componentWillUnmount: ->
    window.removeEventListener "scroll", @handleScroll
    window.removeEventListener "resize", @changePlaceholder


  # Renderers
  #
  renderInsights: ->
    return null if @isEpochType() || !@isRelatedToStory() || (@getInsightsNumber() == 0)

    if !@state.asPlaceholder
      <section className="post-pins">
        <InsightTimelineList 
          pinnable_id={ @props.uuid }
          pinnable_type="Post"
          postUrl = { @state.post.post_url + "#expanded" } />
      </section>
    else
      <div className="post-pins-placeholder"></div>

  renderPinPostItem: ->
    return null if @isEpochType()

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
    return null unless @props.story and !@props.readOnly

    classes = cx
      active: @isRelatedToStory()

    <li onClick={@handleLinkStoryClick} className={classes} >
      <i className="fa fa-link" />
    </li>


  renderStarPostForStoryItem: ->
    # temporary disabled
    return null
    # 

    return null unless @props.story
    posts_story = PostsStoryStore.findByPostAndStoryIds(@props.uuid, @props.story.get('uuid'))
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
      <h2>{formatted_date}</h2>
    else null

    <header key="header">
      {title}
      {date}
    </header>

  renderStories: ->
    story_ids = Immutable.Seq(@state.post.story_ids)

    stories = GlobalState.cursor(['stores', 'stories', 'items']).deref(Immutable.Map())
      .filter (item, key) -> story_ids.contains(key)
      .sortBy (item, key) -> +!!item.get('company_id') + item.get('name')
      .map    @postStoryMapper

    return null if stories.count() == 0

    <div className="cc-hashtag-list">
      <ul>
        { stories.toArray() }
      </ul>
    </div>

  renderPost: ->
    if @isQuote()
      [@renderContent(),
      @renderHeader()]
    else
      [@renderHeader(),
      @renderContent()]

  renderContent: ->
    return null unless @state.blocks.length > 0 and @isRelatedToStory()

    items = @state.blocks.slice(0, 2).map (block) =>
      if block then @identityContentSwitcher(block) else null

    <div className="content" key="content">
      { items[0] }
      { items[1] }
    </div>

  renderReadMore: ->
    return null if @state.blocks.length < 2 && 
                   @state.blocks.every (block) => !@isBlockTruncated(block)

    <span className="read-more">More</span>

  renderFooter: ->
    return null unless @isRelatedToStory()

    <footer>
      { @renderStories() }
    </footer>

  render: ->
    return null unless @isLoaded()

    article_classes = cx
      'preview': true
      'post': true
      'quote': @isQuote()
      'epoch': @isEpochType()
      'only-me': @isOnlyMeVisibility()
      'dimmed': not @isRelatedToStory()

    if !@state.asPlaceholder
      <section id={@props.uuid} className="post-preview-container">
        <article className={article_classes}>
          { @renderControls() }
          <a href={@state.post.post_url} className="for-group">
            { @renderOnlyMeOverlay() }
            { @renderPost() }
            { @renderFooter() }
            { @renderReadMore() }
          </a>
        </article>
        { @renderInsights() }
      </section>
    else
      <section id={@props.uuid} className="post-preview-container">
        <article className="preview post">
          <div className="post-placeholder"></div>
        </article>
        { @renderInsights() }
      </section> 


# Exports
#
module.exports = Component
