# @cjsx React.DOM

# Imports
# 
# SomeComponent = require('')


# Utils
#
# cx = React.addons.classSet


# Main component
# 
module.exports = React.createClass

  # displayName: 'Meaningful name'
  # propTypes:
    # some_object: React.PropTypes.object.isRequired
  # mixins: []
  # statics: {}


  # Component Specifications
  # 
  getDefaultProps: ->
    shouldDisplay: true

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


  # Fetchers
  #
  # fetch: ->


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
    return null unless @props.shouldDisplay

    <section className="cc-container-common banner">
      <header>
        <h1>
          Bite-size insights for&nbsp;founders
        </h1>
        <h2>
          Get valuable insights by successful founders and&nbsp;investors. Share your own.
        </h2>
      </header>
    </section>
