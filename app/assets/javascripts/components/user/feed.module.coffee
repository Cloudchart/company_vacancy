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


  # Component Specifications
  # 
  # getDefaultProps: ->
  # getInitialState: ->


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
    # TODO: filter by insights (content should present)
    ActivityStore.cursor.items.deref(Immutable.Map())
      .sortBy (item) -> item.get('created_at')
      .reverse()
      .take(30)
      .map @renderTrackableItem
      .toArray()
  

  # Handlers
  # 
  # handleThingClick: (event) ->


  # Renderers
  # 
  renderTrackableItem: (item, index) ->
    switch item.get('trackable_type')
      when 'Post'
        <section className="post cloud-card">
          <PostPreview key = { index } uuid = { item.get('trackable_id') } />
        </section>
      when 'Pin'
        <Pin key = { index } uuid = { item.get('trackable_id') } />
          

  # Main render
  # 
  render: ->
    # TODO: show more

    <section className="feed">
      { @gatherFeed() }
    </section>


# Exports
# 
module.exports = MainComponent
