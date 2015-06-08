# @cjsx React.DOM

# Imports
# 
GlobalState = require('global_state/state')
PinStore = require('stores/pin_store')
Insight = require('components/pinboards/pin')


# Utils
#
cx = React.addons.classSet


# Main component
# 
MainComponent = React.createClass

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
  handleInsightClick: (event) ->
    console.log 'handleInsightClick'


  # Renderers
  # 
  # renderSomething: ->


  # Main render
  # 
  render: ->
    <article className="insight-container">
      <Insight
        uuid = { @props.uuid }
        onClick = { @handleInsightClick }
        showAuthor = { false }
      />
    </article>


# Exports
# 
module.exports = MainComponent

