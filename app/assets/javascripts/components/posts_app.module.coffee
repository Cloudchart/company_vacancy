# @cjsx React.DOM


# Imports
# 
tag = React.DOM
cx = React.addons.classSet

GlobalState = require('global_state/state')

# PostStore = require('stores/post_store')
# StoryStore = require('stores/story_store')

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
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->


  # Component Specifications
  # 
  getDefaultProps: ->
    cursor:
      company_flags: GlobalState.cursor(['stores', 'companies', 'flags'])

  # getStateFromProps: (props) ->

  onGlobalStateChange: ->
    @setState
      readOnly: @props.cursor.company_flags.cursor([@props.company_id]).get('is_read_only')

  getInitialState: ->
    readOnly: true

  render: ->
    <div className="wrapper">
      <Timeline 
        company_id = { @props.company_id }
        readOnly = { @state.readOnly }
      />
    </div>


# Exports
# 
module.exports = MainComponent
