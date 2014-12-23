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
createStory = (company_id, post_id, name) ->
  GlobalState
    .cursor(['stores', 'stories', 'create'])
    .update ->
      name:       name
      post_id:    post_id
      company_id: company_id


updateStory = ->
  console.log 'Not implemented'


deleteStory = (uuid) ->
  GlobalState
    .cursor(['stores', 'stories', 'delete'])
    .update ->
      uuid: uuid


filterCreatedStories = (cursor, post_id) ->
  cursor.deref(EmptyStories)
    .filter (story) -> story.has('post_id') and story.get('post_id') == post_id
    .map    (story, key) ->
      id:   key
      name: '#' + story.get('name')
      


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
    # TODO: format story name and query for search

    @state.storiesSeq
      .filter     (story, key) => story.get('company_id') is @props.company_id or story.get('company_id') is null
      .filterNot  (story, key) => @state.selectedStoriesSeq.has(key)
      .filter     (story, key) => story.get('name').toLowerCase().indexOf(@state.query.toLowerCase()) >= 0
      .map        (story, key) => <ComboboxOption key={key} value={key}>{'#' + story.get('name')}</ComboboxOption>
  
  


  # Handlers
  # 
  handleInput: (query) ->
    @setState(query: query)


  handleSelect: (name) ->
    if arguments.length == 1
      createStory(@props.company_id, @props.post_id, name)
    else
      updateStory()


  handleRemove: (object) ->
    deleteStory(object.id)


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
      createdStories: filterCreatedStories(@props.cursor, @props.post_id)

    
    


  getDefaultProps: ->
    cursor: GlobalState.cursor(['stores', 'stories', 'items'])


  # refreshStateFromStores: ->
  # getStateFromStores: ->

  getInitialState: ->
    storiesSeq            = Immutable.Seq(@props.cursor.deref({}))
    storyIdsSeq           = Immutable.Seq(PostStore.get(@props.post_id).story_ids)
    selectedStoriesSeq    = storiesSeq.filter (story, key) -> storyIdsSeq.contains(key)
    
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
