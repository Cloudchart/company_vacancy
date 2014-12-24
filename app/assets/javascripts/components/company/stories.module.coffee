# @cjsx React.DOM

# Imports
# 
tag = React.DOM
cx  = React.addons.classSet

GlobalState   = require('global_state/state')

EmptyStories  = Immutable.List()

PostStore       = require('stores/post_store')
StoryStore      = require('stores/story_store')

TokenInput      = cc.require('plugins/react_tokeninput/main')
ComboboxOption  = cc.require('plugins/react_tokeninput/option')


# Create/Update/Delete
#
createStory = (company_id, name, callbacks = {}) ->
  GlobalState
    .cursor(['stores', 'stories', 'create'])
    .update (stories = EmptyStories) ->
      stories.push Immutable.fromJS
        name:         name
        company_id:   company_id
        callbacks:    callbacks


updateSelectedStories = (story) ->
  console.log 'Not implemented', story


# deleteStory = (uuid) ->
#   GlobalState
#     .cursor(['stores', 'stories', 'delete'])
#     .update ->
#       uuid: uuid


# filterCreatedStories = (cursor, post_id) ->
#   cursor.deref(EmptyStories)
#     .filter (story) -> story.has('post_id') and story.get('post_id') == post_id
#     .map    (story, key) ->
#       id:   key
#       name: '#' + story.get('name')


formatName = (name) ->
  name = name.trim()
  name = name.replace(/[^A-Za-z0-9\-_|\s]+/ig, '')
  name = name.replace(/\s{2,}/g, ' ')
  name = name.replace(/\s/g, '_')


# Main
# 
MainComponent = React.createClass

  mixins: [GlobalState.mixin]
  # propTypes: {}
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
        placeholder = "#Story name"
      />

  
  gatherStoriesForList: ->
    @state.selectedStoriesSeq.map (story, key) ->
      <li key={key}>
        <span key={key}>{'#' + story.get('name')}</span>
      </li>


  filterSelectedStories: ->
    @state.stories().filter((story, key) => @state.storyIdSeq.contains(key))

  
  gatherStories: ->
    @filterSelectedStories()
      .map (story) ->
        id:   story.get('uuid')
        name: '#' + story.get('name')
      .concat @state.createdStories.map((name) -> { id: name, name: '#' + name })
      

  gatherStoriesForSelect: ->
    @state.stories()
      .filter     (story, key) => story.get('company_id') is @props.company_id or story.get('company_id') is null
      .filterNot  (story, key) => @state.selectedStoriesSeq.has(key)
      .filter     (story, key) => story.get('name').toLowerCase().indexOf(@state.query.toLowerCase()) >= 0
      .map        (story, key) => <ComboboxOption key={key} value={key}>{'#' + story.get('name')}</ComboboxOption>
  

  # Handlers
  # 
  handleInput: (query) ->
    @setState(query: query)
  
  
  handleBeforeCreate: (storyId) ->
    console.log 'Before create', storyId


  handleSelect: (name_or_uuid) ->
    formattedName = formatName(name_or_uuid) ; return unless formattedName
    existingStory = @state.stories().get(name_or_uuid, @state.stories().find((story) -> story.get('name') is formattedName))
    createdStory  = @state.createdStories.find((story) -> story.name == formattedName)
    
    return if createdStory
    
    
    if existingStory

      #updateSelectedStories(existingStory)
      @setState
        storyIdSeq: @state.storyIdSeq.concat(existingStory.get('uuid'))

    else
      @setState
        createdStories: @state.createdStories.concat(formattedName).toSet()
      
      StoryStore.create
        company_id: @props.company_id
        name:       formattedName
      , (id) =>
        return unless id
        
        storyIdSeq = @state.storyIdSeq.concat(id)
        
        @setState
          createdStories:     @state.createdStories.remove(@state.createdStories.indexOf(formattedName))
          storyIdSeq:         storyIdSeq
          selectedStoriesSeq: @state.stories().filter((story, key) -> storyIdSeq.contains(key))
        

      # createStory @props.company_id, formattedName,
      #   beforeCreate: @handleBeforeCreate


  handleRemove: (object) ->
    console.log 'handleRemove'
    # deleteStory(object.id)


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
    # TODO: add new story
    # @setState
    #   createdStories: filterCreatedStories(@props.cursor, @props.post_id)
  
  
  componentDidUpdate: (prevProps, prevState) ->
    unless Immutable.is(prevState.storyIdSeq, @state.storyIdSeq)
      console.log 'Should update Post with ids: ', @state.storyIdSeq.toArray()


  getDefaultProps: ->
    cursor: GlobalState.cursor(['stores', 'stories', 'items'])

  # refreshStateFromStores: ->
  # getStateFromStores: ->

  getInitialState: ->
    storiesSeq          = Immutable.Seq(@props.cursor.deref({}))
    storyIdsSeq         = Immutable.Seq(PostStore.get(@props.post_id).story_ids)
    selectedStoriesSeq  = storiesSeq.filter (story, key) -> storyIdsSeq.contains(key)
    
    query:              ''
    stories:            => @props.cursor.deref(EmptyStories)
    storiesSeq:         storiesSeq
    storyIdSeq:         storyIdsSeq.toSet()
    selectedStoriesSeq: selectedStoriesSeq
    createdStories:     Immutable.List()

  render: ->
    <div className="cc-hashtag-list">
      { @getComponentChild() }
    </div>


# Exports
# 
module.exports = MainComponent
