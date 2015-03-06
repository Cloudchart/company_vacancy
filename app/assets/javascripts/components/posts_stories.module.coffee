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
  postsStoriesDeref: ->
    @props.cursor.posts_stories.deref(Immutable.Map())

  getComponentChild: ->
    if @props.readOnly
      <ul>
        {@gatherStoriesForList().toArray()}
      </ul>
    else
      <TokenInput
        isDropdown  = true
        onInput     = {@handleInput}
        onSelect    = {@handleSelect}
        onRemove    = {@handleRemove}
        selected    = {@gatherStories().toArray()}
        menuContent = {@gatherStoriesForSelect().toArray()}
        placeholder = {@props.placeholder}
      />

  
  gatherStoriesForList: ->
    @filterSelectedStories()
      .sortBy (story) -> story.get('name')
      .map (story) =>
        # company_story_url = @props.cursor.stories.get(story.get('uuid')).get('company_story_url')
        
        <li key={story.get('uuid')}>
          <span>{'#' + story.get('formatted_name')}</span>
        </li>
        # <a href={company_story_url}>{'#' + story.get('name')}</a>


  filterSelectedStories: ->
    @props.cursor.stories.filter (story) => @state.storyIdSeq.contains(story.get('uuid'))

  
  gatherStories: ->
    @filterSelectedStories()
      .map (story) ->
        id:   story.get('uuid')
        name: '#' + story.get('formatted_name')
      .sortBy (object) -> object.name


  gatherStoriesForSelect: ->
    @props.cursor.stories
      .filter     (story, key) => story.get('company_id') is @props.company_id or story.get('company_id') is null
      .filterNot  (story, key) => @state.storyIdSeq.contains(key)
      .filter     (story, key) => (@state.query.length > 0 && story.get('formatted_name').toLowerCase().indexOf(@state.query.toLowerCase()) == 0) || (@state.query.length == 0 && story.get('company_id') is null)
      .sortBy     (story, key) => story.get('name')
      .map        (story, key) => <ComboboxOption key={key} value={key}>{'#' + story.get('formatted_name')}</ComboboxOption>


  getStoryIdSeq: ->
    @postsStoriesDeref()
      .valueSeq()
      .filter (posts_story) => posts_story.get('post_id') is @props.post_id
      .map (posts_story) -> posts_story.get('story_id')
      .toSet()

  createPostsStory: (story_id) ->
    PostsStoryStore.create(@props.post_id, story_id: story_id)

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
    existingStory = @props.cursor.stories.get(name_or_uuid, @props.cursor.stories.find((story) -> story.get('formatted_name') is formattedName))
    
    if existingStory
      @createPostsStory(existingStory.get('uuid'))

    else
      StoryStore.createByCompany(@props.company_id, name: formattedName).then(@handleStoryCreateDone)

    @setState(query: "")
        

  handleRemove: (object) ->
    @destroyPostsStory(object.id)

  handleStoryCreateDone: (json) ->
    @createPostsStory(json.id)


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
    placeholder: '#Category'

    cursor: 
      stories: StoryStore.cursor.items
      posts_stories: PostsStoryStore.cursor.items

  getInitialState: ->
    query: ''
    storyIdSeq: @getStoryIdSeq()

  render: ->
    <div className="cc-hashtag-list stories">
      { @getComponentChild() }
    </div>


# Exports
# 
module.exports = MainComponent
