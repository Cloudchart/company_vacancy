# @cjsx React.DOM

# Imports
# 
tag = React.DOM
cx  = React.addons.classSet

EmptyStories    = Immutable.List()

GlobalState     = require('global_state/state')

PostStore       = require('stores/post_store')
StoryStore      = require('stores/story_store')

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

  # mixins: []
  propTypes:
    onChange: React.PropTypes.func

  displayName: 'Stories'


  # Helpers
  # 
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
    # <span>{'#' + story.get('name')}</span>
    @filterSelectedStories().map (story) =>
      company_story_url = @props.cursor.get(story.get('uuid')).get('company_story_url')
      
      <li key={story.get('uuid')}>
        <a href={company_story_url}>{'#' + story.get('name')}</a>
      </li>


  filterSelectedStories: ->
    @state.storyIdSeq.map (id) => @state.stories().get(id)

  
  gatherStories: ->
    @filterSelectedStories()
      .map (story) ->
        id:   story.get('uuid')
        name: '#' + story.get('name')
      .concat @state.createdStories.map((name) -> { id: name, name: '#' + name })


  gatherStoriesForSelect: ->
    @state.stories()
      .filter     (story, key) => story.get('company_id') is @props.company_id or story.get('company_id') is null
      .filterNot  (story, key) => @state.storyIdSeq.contains(key)
      .filter     (story, key) => story.get('name').toLowerCase().indexOf(@state.query.toLowerCase()) >= 0
      .map        (story, key) => <ComboboxOption key={key} value={key}>{'#' + story.get('name')}</ComboboxOption>


  updateStoryIds: (storyIdSeq) ->
    @setState storyIdSeq: storyIdSeq
    @props.onChange(storyIdSeq.toArray())
  

  # Handlers
  # 
  handleInput: (query) ->
    @setState(query: query)


  handleSelect: (name_or_uuid) ->
    formattedName = formatName(name_or_uuid) ; return unless formattedName
    existingStory = @state.stories().get(name_or_uuid, @state.stories().find((story) -> story.get('name') is formattedName))
    createdStory  = @state.createdStories.find((story) -> story.name == formattedName)
    
    return if createdStory
    
    if existingStory
      @updateStoryIds(@state.storyIdSeq.concat(existingStory.get('uuid')))

    else
      @setState
        createdStories: @state.createdStories.concat(formattedName).toSet()
      
      StoryStore.create
        company_id: @props.company_id
        name:       formattedName
      , (id) =>
        return unless id
        @updateStoryIds(@state.storyIdSeq.concat(id))
        

  handleRemove: (object) ->
    @updateStoryIds(@state.storyIdSeq.filterNot((id) -> id is object.id))


  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->

  componentWillReceiveProps: (nextProps) ->
    @setState @getStateFromProps(nextProps)

  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->


  # Component Specifications
  # 
  getDefaultProps: ->
    cursor: GlobalState.cursor(['stores', 'stories', 'items'])

  getStateFromProps: (props) ->
    storyIdSeq: Immutable.Seq(PostStore.get(props.post_id).story_ids).toSet()
    createdStories: Immutable.List()

  getInitialState: ->
    _.extend @getStateFromProps(@props), 
      query:   ''
      stories: => @props.cursor.deref(EmptyStories)

  render: ->
    <div className="cc-hashtag-list">
      { @getComponentChild() }
    </div>


# Exports
# 
module.exports = MainComponent
