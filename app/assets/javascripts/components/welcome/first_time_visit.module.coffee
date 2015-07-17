# @cjsx React.DOM

# Imports
# 
# SomeComponent = require('')


# Utils
#
Constants = require('constants')
# cx = React.addons.classSet


# Main component
# 
module.exports = React.createClass

  # displayName: 'Meaningful name'
  # mixins: []
  # statics: {}
  # propTypes:
    # some_object: React.PropTypes.object.isRequired


  # Component Specifications
  # 
  # getDefaultProps: ->

  getInitialState: ->
    shouldDisplay: true

  
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
  handleCloseClick: (event) ->
    @setState shouldDisplay: false

  handleGoToRootClick: (event) ->
    location.href = '/'


  # Renderers
  # 
  # renderSomething: ->


  # Main render
  # 
  render: ->
    return null unless @state.shouldDisplay

    <div className="first-time-visit">
      <button className="close transparent" onClick={@handleCloseClick}>
        <i className="fa cc-icon cc-times"></i>
      </button>

      <p>
        { "First time on #{Constants.SITE_NAME}? We created it to help founders solve problems they face everyday. Discover helpful insights by successful founders, investors and experts. Create your own insight collections. Share with your team and the community!" }
      </p>

      <footer>
        <button className="cc black" onClick={@handleGoToRootClick}>Get started</button>
      </footer>
    </div>
