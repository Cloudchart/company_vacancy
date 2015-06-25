# @cjsx React.DOM

# Imports
# 
ModalStack = require('components/modal_stack')
CloseModalButton = require('components/form/buttons').CloseModalButton


# Utils
#
# cx = React.addons.classSet


# Main component
# 
module.exports = React.createClass

  displayName: 'ModalSplash'

  propTypes:
    message: React.PropTypes.string.isRequired
  
  # mixins: []
  # statics: {}


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
  # getSomething: ->


  # Handlers
  # 
  handleClick: (event) ->
    ModalStack.hide()


  # Renderers
  # 
  # renderSomething: ->


  # Main render
  # 
  render: ->
    <div className="splash">
      <CloseModalButton/>
      <figure className="cloud-chart"></figure>
      <p dangerouslySetInnerHTML = { __html: @props.message } />
      <button className="cc" onClick={@handleClick}>Okay</button>
    </div>
