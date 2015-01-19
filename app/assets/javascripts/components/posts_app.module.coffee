# @cjsx React.DOM


# Imports
# 
tag = React.DOM
cx = React.addons.classSet

GlobalState = require('global_state/state')

PostStore = require('stores/post_store')
CompanyStore = require('stores/company')

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
    PostStore.on('change', @refreshStateFromStores)

  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)
    PostStore.off('change', @refreshStateFromStores)


  # Component Specifications
  # 
  getDefaultProps: ->
    cursor:
      company_flags: GlobalState.cursor(['stores', 'companies', 'flags'])
      story: GlobalState.cursor(['stores', 'stories', 'items'])

  refreshStateFromStores: ->
    @setState @getStateFromProps(@props)

  getStateFromProps: (props) ->
    company: CompanyStore.get(props.company_id)

  onGlobalStateChange: ->
    @setState
      readOnly: @props.cursor.company_flags.cursor([@props.company_id]).get('is_read_only')

  getInitialState: ->
    _.extend @getStateFromProps(@props),
      readOnly: true

  render: ->
    <div className="wrapper">
      <div className="story">
        { @props.story.get('name') }
      </div>

      <Timeline 
        company_id = { @props.company_id }
        story = { @props.story }
        readOnly = { @state.readOnly }
      />
    </div>


# Exports
# 
module.exports = MainComponent
