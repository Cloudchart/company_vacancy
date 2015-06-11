# @cjsx React.DOM

# Imports
# 
GlobalState = require('global_state/state')
PinStore = require('stores/pin_store')
Insight = require('components/cards/insight_card')


# Utils
#
# cx = React.addons.classSet


# Main component
# 
module.exports = React.createClass

  displayName: 'InsightApp'
  mixins: [GlobalState.mixin]
  # statics: {}
  # propTypes: {}


  # Component Specifications
  # 
  getDefaultProps: ->
    cursor: 
      pins: PinStore.cursor.items

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
  # getSomething: ->


  # Handlers
  # 
  # handleThingClick: (event) ->


  # Renderers
  # 
  # renderSomething: ->


  # Main render
  # 
  render: ->
    <Insight insight = { @props.uuid } />
