# @cjsx React.DOM

# Imports
# 
tag = React.DOM
cx = React.addons.classSet

GlobalState = require('global_state/state')

StoryStore = require('stores/story_store')
PostStore = require('stores/post_store')
PostsStoryStore = require('stores/posts_story_store')
PinStore = require('stores/pin_store')


# Main component
# 
MainComponent = React.createClass

  mixins: [GlobalState.mixin]
  # propTypes: {}
  # displayName: 'Meaningful name'


  # Helpers
  # 
  storiesDeref: ->
    @props.cursor.stories.deref(Immutable.Map())

  pinsDeref: ->
    @props.cursor.pins.deref(Immutable.Map())

  getPostsSizeForStory: (story) ->


  getPinsSizeForStory: (story) ->
    size = @pinsDeref()
      # .filter (pin) -> pin.get('pinnable_id')
      .size


  # Handlers
  # 
  handleStoryClick: (event) ->
    console.log 'handleStoryClick'


  # Lifecycle Methods
  # 
  # componentWillMount: ->

  componentDidMount: ->
    return if StoryStore.cursor.items.deref(Immutable.Map()).size > 0
    StoryStore.fetchAll(@props.company_id)

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

  getDefaultProps: ->
    cursor:
      stories: StoryStore.cursor.items
      pins: PinStore.cursor.items

  # getInitialState: ->


  # Renderers
  # 
  renderStories: ->
    stories = @storiesDeref()
      .sortBy (story) -> story.get('name')
      .map (story) => @storyItemMapper(story)

    <ul className="stories-list">
      { stories.toArray() }
    </ul>

  storyItemMapper: (story) ->
    <li key={story.get('uuid')} onClick={@handleStoryClick} >
      <h3>{ story.get('name') }</h3>
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
    return null if @storiesDeref().size is 0
    # TODO: figure out about extra render

    # console.log PostStore.all()

    <div className="wrapper">
      <h1>Stories</h1>
      { @renderStories() }
    </div>


# Exports
# 
module.exports = MainComponent
