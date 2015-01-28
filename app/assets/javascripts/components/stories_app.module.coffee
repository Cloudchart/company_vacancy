# @cjsx React.DOM

# Imports
# 
GlobalState = require('global_state/state')


# Stores
#
StoryStore      = require('stores/story_store')
PostStore       = require('stores/post_store.cursor')
PostsStoryStore = require('stores/posts_story_store.cursor')
PinStore        = require('stores/pin_store')


# Utils
#
cx = React.addons.classSet
  
  
# Main component
# 
MainComponent = React.createClass

  displayName: 'StoriesApp'


  mixins: [GlobalState.mixin]


  # Helpers
  # 
  
  getPostIds: (story) ->
    @props.cursor.posts_stories
      .filter (posts_story) => posts_story.get('story_id') is story.get('uuid')
      .map    (posts_story) -> posts_story.get('post_id')
      .valueSeq()


  getPostsSizeForStory: (story) ->
    @getPostIds(story).size


  getPinsSizeForStory: (story) ->
    postIds = @getPostIds(story)

    @props.cursor.pins
      .filter (pin) -> postIds.contains(pin.get('pinnable_id'))
      .size


  # Handlers
  # 
  handleStoryClick: (url, event) ->
    location.href = url


  # Lifecycle Methods
  # 
  # componentWillMount: ->

  componentDidMount: ->
    StoryStore.fetchAllByCompany(@props.company_id) unless StoryStore.cursor.items.deref()


  # Component Specifications
  # 
  onGlobalStateChange: ->
    @setState @getStateFromStores()
  
  
  getStateFromStores: ->
    {}


  getDefaultProps: ->
    cursor:
      posts_stories:  PostsStoryStore.cursor.items
      stories:        StoryStore.cursor.items
      posts:          PostStore.cursor.items
      pins:           PinStore.cursor.items
  
  
  # Renderers
  # 
  renderStories: ->
    stories = @props.cursor.stories
      .sortBy (story) -> story.get('name')
      .map @storyItemMapper

    <ul className="stories-list">
      { stories.toArray() }
    </ul>


  storyItemMapper: (story, uuid) ->
    <li key={ uuid } onClick={ @handleStoryClick.bind(@, story.get('company_story_url')) } >

      <h3>{ story.get('formatted_name', story.get('name')) }</h3>

      <div className="description" dangerouslySetInnerHTML={__html: story.get('description')} />

      <br />

      <div className="posts-counter">
        Posts: { @getPostsSizeForStory(story) }
      </div>

      <div className="pins-counter">
        Pins: { @getPinsSizeForStory(story) }
      </div>
    </li>


  # Main render
  # 
  render: ->
    return null unless @props.cursor.stories.deref()

    <div className="wrapper">
      <h1>Stories</h1>
      { @renderStories() }
    </div>


# Exports
# 
module.exports = MainComponent
