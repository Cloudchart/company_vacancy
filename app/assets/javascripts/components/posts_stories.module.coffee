# @cjsx React.DOM

# Imports
# 
tag = React.DOM
cx  = React.addons.classSet

GlobalState     = require('global_state/state')

StoryStore      = require('stores/story_store')
PostsStoryStore = require('stores/posts_story_store')

TokenInput      = cc.require('plugins/react_tokeninput/main')
ComboboxOption  = cc.require('plugins/react_tokeninput/option')


# Module helpers
# 
formatName = (name) ->
  name = name.trim()
  name = name.replace(/[^A-Za-z0-9\-_|\s]+/ig, '')
  name = name.replace(/\s{2,}/g, ' ')


# Main
# 
MainComponent = React.createClass

  mixins: [GlobalState.mixin]
  # propTypes:
  #   onChange: React.PropTypes.func

  displayName: 'Posts Stories'


  # Helpers
  # 
  storiesDeref: ->
    @props.cursor.stories.deref(Immutable.List())

  postsStoriesDeref: ->
    @props.cursor.posts_stories.deref(Immutable.Map())

  getComponentChild: ->
    if @props.readOnly
      <ul>
        {@gatherStoriesForList().toArray()}
      </ul>
    else
      <TokenInput
        onInput     = {@handleInput}
        onSelect    = {@handleSelect}
        onRemove    = {@handleRemove}
        selected    = {@gatherStories().toArray()}
        menuContent = {@gatherStoriesForSelect().toArray()}
        placeholder = "#Event tag"
      />

  
  gatherStoriesForList: ->
    @filterSelectedStories()
      .sortBy(story) -> story.get('name')
      .map (story) =>
        company_story_url = @props.cursor.stories.get(story.get('uuid')).get('company_story_url')
        
        <li key={story.get('uuid')}>
          <a href={company_story_url}>{'#' + story.get('name')}</a>
        </li>
        # <span>{'#' + story.get('name')}</span>


  filterSelectedStories: ->
    @state.storyIdSeq.map (id) => @storiesDeref().get(id)

  
  gatherStories: ->
    @filterSelectedStories()
      .map (story) ->
        id:   story.get('uuid')
        name: '#' + story.get('name')
      .concat @state.createdStories.map((name) -> { id: name, name: '#' + name })
      .sortBy (object) -> object.name


  gatherStoriesForSelect: ->
    @storiesDeref()
      .filter     (story, key) => story.get('company_id') is @props.company_id or story.get('company_id') is null
      .filterNot  (story, key) => @state.storyIdSeq.contains(key)
      .filter     (story, key) => story.get('name').toLowerCase().indexOf(@state.query.toLowerCase()) >= 0
      .sortBy     (story, key) => story.get('name')
      .map        (story, key) => <ComboboxOption key={key} value={key}>{'#' + story.get('name')}</ComboboxOption>


  getStoryIdSeq: ->
    @postsStoriesDeref()
      .valueSeq()
      .filter (posts_story) => posts_story.get('post_id') is @props.post_id
      .map (posts_story) -> posts_story.get('story_id')
      .toSet()

  createPostsStroy: (story_id) ->
    @setState storyIdSeq: @state.storyIdSeq.concat(story_id)
    PostsStoryStore.create(@props.post_id, { story_id: story_id })

  destroyPostsStory: (story_id) ->
    @setState storyIdSeq: @state.storyIdSeq.filterNot((id) -> id is story_id)
    id = PostsStoryStore.findByPostAndStoryIds(@props.post_id, story_id).get('uuid')
    PostsStoryStore.destroy(id)
  

  # Handlers
  # 
  handleInput: (query) ->
    @setState(query: query)

  handleSelect: (name_or_uuid) ->
    formattedName = formatName(name_or_uuid) ; return unless formattedName
    existingStory = @storiesDeref().get(name_or_uuid, @storiesDeref().find((story) -> story.get('name') is formattedName))
    
    if existingStory
      @createPostsStroy(existingStory.get('uuid'))

    else
      @setState createdStories: @state.createdStories.concat(formattedName).toSet()
      
      StoryStore.create
        company_id: @props.company_id
        name:       formattedName
      , (id) =>
        return unless id
        @setState createdStories: Immutable.List()
        @createPostsStroy(id)
        

  handleRemove: (object) ->
    @destroyPostsStory(object.id)


  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->


  # Component Specifications
  # 
  onGlobalStateChange: ->
    @setState
      refreshed_at: + new Date
      storyIdSeq: @getStoryIdSeq()

  getDefaultProps: ->
    cursor: 
      stories: StoryStore.cursor.items
      posts_stories: PostsStoryStore.cursor.items

  getInitialState: ->
    query: ''
    storyIdSeq: @getStoryIdSeq()
    createdStories: Immutable.List()

  render: ->
    <div className="cc-hashtag-list">
      { @getComponentChild() }
    </div>


# Exports
# 
module.exports = MainComponent
