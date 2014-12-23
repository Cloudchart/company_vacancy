# @cjsx React.DOM

# Imports
# 
tag = React.DOM
cx = React.addons.classSet

GlobalState = require('global_state/state')

EmptyStories = Immutable.Seq()

PostStore = require('stores/post_store')

TokenInput = cc.require('plugins/react_tokeninput/main')
ComboboxOption = cc.require('plugins/react_tokeninput/option')

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
    @state.selectedStoriesSeq.map (story, key) ->
      id: key
      name: '#' + story.get('name')

  gatherStoriesForSelect: ->
    # TODO: format story name and query for search

    @state.storiesSeq
      .filter (story, key) => story.get('company_id') is @props.company_id or story.get('company_id') is null
      .filter (story, key) => not @state.selectedStoriesSeq.has(key)
      .filter (story, key) => story.get('name').toLowerCase().indexOf(@state.query.toLowerCase()) >= 0
      .map (story, key) -> <ComboboxOption key={key} value={key}>{'#' + story.get('name')}</ComboboxOption>

  # Handlers
  # 
  handleInput: (query) ->
    @setState(query: query)

  handleSelect: (name) ->
    console.log name

  handleRemove: (object) ->
    console.log object

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
    console.log 'onGlobalStateChange'

  getDefaultProps: ->
    cursor: GlobalState.cursor(['stores', 'stories', 'items'])

  # refreshStateFromStores: ->
  # getStateFromStores: ->

  getInitialState: ->
    storiesSeq = Immutable.Seq(@props.cursor.deref({}))
    storyIdsSeq = Immutable.Seq(PostStore.get(@props.post_id).story_ids)
    selectedStoriesSeq = storiesSeq.filter (story, key) -> storyIdsSeq.contains(key)

    query: ''
    storiesSeq: storiesSeq
    selectedStoriesSeq: selectedStoriesSeq

  render: ->
    # return null if
    <div className="cc-hashtag-list">{@getComponentChild()}</div>

# Exports
# 
module.exports = MainComponent
