# @cjsx React.DOM

# Imports
# 
GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')
PostStore = require('stores/post_store.cursor')
CompanyStore = require('stores/company_store.cursor')
UserStore = require('stores/user_store.cursor')


# Utils
#
# cx = React.addons.classSet


# Main component
# 
module.exports = React.createClass

  displayName: 'InsightCard'
  
  mixins: [GlobalState.query.mixin]
  # propTypes: {}

  statics:
    queries:
      insight: ->
        """
          Pin {
            user,
            post {
              company
            }
          }
        """


  # Component Specifications
  # 
  # getDefaultProps: ->
  # getInitialState: ->

  
  # Lifecycle Methods
  # 
  componentWillMount: ->
    @cursor = 
      pins: PinStore.cursor.items
      companies: CompanyStore.cursor.items
      posts: PostStore.cursor.items

    @fetch()

  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->


  # Helpers
  # 
  getInsight: ->
    if typeof(@props.insight) is 'string'
      @cursor.pins.cursor(@props.insight).deref(Immutable.Map({})).toJS()
    else if typeof(@props.insight) is 'object'
      @props.insight

  fetch: ->
    id = if typeof(@props.insight) is 'string'
      @props.insight
    else if typeof(@props.insight) is 'object'
      @props.insight.uuid

    GlobalState.fetch(@getQuery('insight'), id: id)


  # Handlers
  # 
  # handleThingClick: (event) ->


  # Renderers
  # 
  renderPlaceholder: ->
    console.log 'renderPlaceholder'
    null

  renderInsight: ->
    console.log 'renderInsight'
    null


  # Main render
  # 
  render: ->
    console.log @getInsight()
    if Object.keys(@getInsight()).length is 0
      @renderPlaceholder()
    else
      @renderInsight()
