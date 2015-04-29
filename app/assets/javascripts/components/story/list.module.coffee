# @cjsx React.DOM

# Imports
# 
GlobalState = require('global_state/state')

CompanyStore = require('stores/company')
StoryStore = require('stores/story_store')
PostsStoryStore = require('stores/posts_story_store.cursor')
PinStore = require('stores/pin_store')


# Utils
#
cx = React.addons.classSet


# Main component
# 
MainComponent = React.createClass

  displayName: 'StoriesList'
  mixins: [GlobalState.mixin]
  # statics: {}
  propTypes:
    company_id: React.PropTypes.string.isRequired
    readOnly:   React.PropTypes.bool


  # Component Specifications
  # 
  getDefaultProps: ->
    readOnly: true
    cursor:
      stories:       StoryStore.cursor.items
      posts_stories: PostsStoryStore.cursor.items
      pins:          PinStore.cursor.items

  getInitialState: ->
    company: CompanyStore.get(@props.company_id)

  onGlobalStateChange: ->
    @setState refreshed_at: + new Date

  
  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->


  # Helpers
  # 
  isLoaded: ->
    @props.cursor.stories.deref(false) and @props.cursor.posts_stories.deref(false) and @props.cursor.pins.deref(false)

  getPostsSizeForStory: (story) ->
    story_id = story.get('uuid')
    post_ids = @state.company.post_ids

    @props.cursor.posts_stories
      .filter (posts_story) -> posts_story.get('story_id') is story_id and post_ids.contains(posts_story.get('post_id'))
      .size

  getPinsSizeForStory: (story) ->
    story_id = story.get('uuid')
    post_ids = @props.cursor.posts_stories
      .filter (posts_story) -> posts_story.get('story_id') is story_id
      .map (posts_story) -> posts_story.get('post_id')
      .valueSeq()
    
    @props.cursor.pins
      .filter (pin) -> pin.get('is_approved') and !pin.get('parent_id') and 
                       pin.get('pinboard_id') and pin.get('pinnable_id') and 
                       post_ids.contains(pin.get('pinnable_id'))
      .size


  # Handlers
  # 
  handleStoryClick: (story) ->
    location.hash = "story-#{story.get('name')}"

  handleBackToTimelineClick: ->
    location.hash = 'timeline'


  # Renderers
  # 
  renderStories: ->
    stories = @props.cursor.stories
      .filter (story) -> story.get('posts_stories_count')
      .sortBy (story) -> +!!story.get('company_id') + story.get('name')
      .map @storyItemMapper

    <ul className="stories list">
      <li onClick = { @handleBackToTimelineClick } >
        <header>
          <h3>Everything</h3>
        </header>
        <div className="content">{ "Story of #{@state.company.name}" }</div>
      </li>

      { stories.toArray() }
    </ul>

  storyItemMapper: (story, uuid) ->
    posts_count = @getPostsSizeForStory(story)
    return null unless posts_count >= 5 || 
                       !story.get('company_id') && posts_count > 0 ||
                       !@props.readOnly

    storyClassName = if posts_count < 5 then 'inactive' else null                 

    pins_count = @getPinsSizeForStory(story)

    <li className={ storyClassName } key={ uuid } onClick={ @handleStoryClick.bind(@, story) } >
      <header>
        <h3>{ '#' + story.get('formatted_name') }</h3>
      </header>
      <div className="content" dangerouslySetInnerHTML={__html: story.get('description')} />
      <footer>
        { "#{posts_count} posts, #{pins_count} insights" }
      </footer>
    </li>


  # Main render
  # 
  render: ->
    return null unless @isLoaded()

    <section className="stories">
      { @renderStories() }
    </section>


# Exports
# 
module.exports = MainComponent
