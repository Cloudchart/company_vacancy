# @cjsx React.DOM

# Imports
# 
tag = React.DOM
cx  = React.addons.classSet

GlobalState   = require('global_state/state')

EmptyStories  = Immutable.Seq()

PostStore       = require('stores/post_store')

TokenInput      = cc.require('plugins/react_tokeninput/main')
ComboboxOption  = cc.require('plugins/react_tokeninput/option')


# Create/Update/Delete
#
createStory = (company_id, name) ->
  GlobalState
    .cursor(['stores', 'stories', 'create'])
    .update ->
      company_id: company_id
      name:       name


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

  
  gatherStories: ->
    @state.selectedStoriesSeq.valueSeq()
      .map (story) ->
        id:   story.get('uuid')
        name: '#' + story.get('name')
      .concat @state.createdStories
      

  gatherStoriesForSelect: ->
    @state.storiesSeq
      .filter     (story, key) => story.get('company_id') is @props.company_id or story.get('company_id') is null
      .filterNot  (story, key) => @state.selectedStoriesSeq.has(key)
      .filter     (story, key) => story.get('name').toLowerCase().indexOf(@state.query.toLowerCase()) >= 0
      .map        (story, key) => <ComboboxOption key={key} value={key}>{'#' + story.get('name')}</ComboboxOption>
  

  # Handlers
  # 
  handleInput: (query) ->
    @setState(query: query)


  handleSelect: (name_or_uuid) ->
    if story = @state.storiesSeq.valueSeq().find((story) -> story.get('uuid') is name_or_uuid or story.get('name') is name_or_uuid)
      updateSelectedStories(story)
    else
      name = formatName(name_or_uuid) ; return unless name
      createStory(@props.company_id, name)


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

  getDefaultProps: ->
    cursor: GlobalState.cursor(['stores', 'stories', 'items'])

  # refreshStateFromStores: ->
  # getStateFromStores: ->

  getInitialState: ->
    storiesSeq          = Immutable.Seq(@props.cursor.deref({}))
    storyIdsSeq         = Immutable.Seq(PostStore.get(@props.post_id).story_ids)
    selectedStoriesSeq  = storiesSeq.filter (story, key) -> storyIdsSeq.contains(key)
    
    query:              ''
    storiesSeq:         storiesSeq
    selectedStoriesSeq: selectedStoriesSeq
    createdStories:     Immutable.Seq()

  render: ->
    <div className="cc-hashtag-list">
      { @getComponentChild() }
    </div>


# Exports
# 
module.exports = MainComponent
