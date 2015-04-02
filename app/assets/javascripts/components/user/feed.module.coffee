# @cjsx React.DOM

# Imports
# 
UserStore = require('stores/user_store.cursor')
ActivityStore = require('stores/activity_store')

PostPreview = require('components/pinnable/post')
Pin = require('components/pinboards/pin')


# Utils
#
cx = React.addons.classSet


# Main component
# 
MainComponent = React.createClass

  displayName: 'User feed'
  # mixins: []
  # propTypes: {}

  statics:
    isEmpty: ->
      !ActivityStore.cursor.items.deref(Immutable.Map()).size


  # Component Specifications
  # 
  # getDefaultProps: ->
  getInitialState: ->
    offset: 0
    limit: 10


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
  gatherFeed: ->
    ActivityStore.cursor.items.deref(Immutable.Map())
      .sortBy (item) -> item.get('created_at')
      .reverse()
      .slice(0, @state.offset + @state.limit)
      .map @renderTrackableItem
      .toArray()
  

  # Handlers
  # 
  handleShowMoreClick: (event) ->
    @setState offset: @state.offset + @state.limit


  # Renderers
  # 
  renderTrackableItem: (item, index) ->
    switch item.get('trackable_type')
      when 'Post'
        <section key = { index } className="post cloud-card">
          <PostPreview uuid = { item.get('trackable_id') } />
        </section>
      when 'Pin'
        <Pin key = { index } uuid = { item.get('trackable_id') } />

  renderShowMoreButton: ->
    return null if ActivityStore.cursor.items.deref(Immutable.Map()).size <= @state.offset + @state.limit
    <button className="cc" onClick={@handleShowMoreClick}> Show more </button>
          

  # Main render
  # 
  render: ->
    <section className="feed">
      { @gatherFeed() }
      { @renderShowMoreButton() }
    </section>


# Exports
# 
module.exports = MainComponent
