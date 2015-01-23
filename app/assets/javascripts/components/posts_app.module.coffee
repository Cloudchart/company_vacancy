# @cjsx React.DOM


# Imports
# 
tag = React.DOM
cx = React.addons.classSet

GlobalState = require('global_state/state')

PostStore = require('stores/post_store')
CompanyStore = require('stores/company')
PostsStoryStore = require('stores/posts_story_store')

Timeline = require('components/company/timeline')


# Main
# 
MainComponent = React.createClass

  mixins: [GlobalState.mixin]
  # propTypes: {}
  displayName: 'Posts app'


  # Helpers
  # 
  # gatherSomething: ->


  # Handlers
  # 
  # handleThingClick: (event) ->


  # Lifecycle Methods
  # 
  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)

  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)


  # Component Specifications
  # 
  getDefaultProps: ->
    cursor:
      company_flags: GlobalState.cursor(['stores', 'companies', 'flags'])
      story: GlobalState.cursor(['stores', 'stories', 'items'])
      posts_story: PostsStoryStore.cursor.items

  refreshStateFromStores: ->
    @setState @getStateFromProps(@props)

  getStateFromProps: (props) ->
    company: CompanyStore.get(props.company_id)

  onGlobalStateChange: ->
    @setState
      refreshed_at: + new Date
      readOnly: @props.cursor.company_flags.cursor([@props.company_id]).get('is_read_only')

  getInitialState: ->
    _.extend @getStateFromProps(@props),
      readOnly: true

  render: ->
    story = @props.cursor.story.cursor(@props.story_id)
    return null unless story.deref(Immutable.Map()).size > 0

    <div className="wrapper">
      <h1>{story.get('name')}</h1>

      <Timeline 
        company_id = { @props.company_id }
        story_id = { @props.story_id }
        readOnly = { @state.readOnly }
      />
    </div>


# Exports
# 
module.exports = MainComponent
