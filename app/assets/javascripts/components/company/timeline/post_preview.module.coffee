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

PostActions = require('actions/post_actions')
VisibilityActions = require('actions/visibility_actions')

Post = require('components/post')
ContentEditableArea = require('components/form/contenteditable_area')
PersonAvatar = require('components/shared/person_avatar')

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
    Stories   = GlobalState.cursor(['stores', 'stories', 'items']).deref()

    return null unless Stories
    
    postStoryIds  = Immutable.Seq(@state.post.story_ids)

    stories = Stories
      .filter (item, key) -> postStoryIds.contains(key)
      .sortBy (item, key) -> postStoryIds.indexOf(key)
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
    <div className="content">
      { @getFirstParagraph() }
      { @getFirstPerson() }
      { @gatherPictures() }
    </div>


  postStoryMapper: (story, key) ->
    <li key={key}>
      { '#' + story.get('name') }
    </li>


  getFirstParagraph: ->
    block = _.chain @state.blocks
      .filter (block) -> block.identity_type is 'Paragraph'
      .sortBy('position')
      .first()
      .value()

    return null unless block
    
    paragraph = ParagraphStore.find (paragraph) -> paragraph.owner_id is block.uuid

    return null unless paragraph

    parts = paragraph.content.match(/<div>(.*?)<\/div>/i)
    content = "<div>#{_.str.truncate(parts[1], 600)}</div>"
    classes = cx
      'paragraph': true
      'quote': block.kind is 'Quote'

    <div className={classes} dangerouslySetInnerHTML={__html: content}></div>


  gatherPictures: ->
    pictures = _.chain @state.blocks
      .filter (block) -> block.identity_type is 'Picture'
      .sortBy('position')
      .map (block) -> PictureStore.find (picture) -> picture.owner_id is block.uuid
      .compact()
      .value()

    return null unless pictures.length > 0

    # left only cover for now
    <img className="cover" src={pictures[0].url}/>

    # if pictures.length is 1
    #   <img className="cover" src={pictures[0].url}/>
    # else
    #   <ul className="pictures">
    #     {
    #       _.map pictures, (picture) -> 
    #         <li key={picture.uuid} style={'background-image': "url(#{picture.url})"}></li>
    #     }
    #   </ul>


  getFirstPerson: ->
    first_paragraph_block = _.chain @state.blocks
      .filter (block) -> block.identity_type is 'Paragraph'
      .sortBy('position')
      .first()
      .value()

    return null unless first_paragraph_block and first_paragraph_block.kind is 'Quote'

    firt_person_block = _.chain @state.blocks
      .filter (block) -> block.identity_type is 'Person'
      .sortBy('position')
      .first()
      .value()

    return null unless firt_person_block

    person = PersonStore.get(firt_person_block.identity_ids.toJS()[0])

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
    @state.post.title and @state.post.effective_from and @state.post.effective_till and 
      (@state.blocks.length is 0 or 
        (@state.blocks.length is 1 and @state.blocks[0].identity_type is 'Paragraph' and
          !ParagraphStore.find (paragraph) => paragraph.owner_id is @state.blocks[0].uuid))


  # Handlers
  # 
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


  # Lifecycle Methods
  # 
  componentDidMount: ->
    BlockStore.on('change', @refreshStateFromStores)
    ParagraphStore.on('change', @refreshStateFromStores)
    PictureStore.on('change', @refreshStateFromStores)
    VisibilityStore.on('change', @refreshStateFromStores)

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  componentWillUnmount: ->
    BlockStore.off('change', @refreshStateFromStores)
    ParagraphStore.off('change', @refreshStateFromStores)
    PictureStore.off('change', @refreshStateFromStores)
    VisibilityStore.off('change', @refreshStateFromStores)


  # Component Specifications
  # 
  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))

  getStateFromStores: (props) ->
    visibility = VisibilityStore.find (item) -> item.uuid and item.owner_id is props.uuid and item.owner_type is 'Post'

    post: PostStore.get(props.uuid)
    blocks: BlockStore.filter (block) => block.owner_id is @props.uuid
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
