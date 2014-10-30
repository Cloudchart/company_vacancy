# @cjsx React.DOM

# Imports
# 
tag = React.DOM

# SomeComponent = require('')

# Main
# 
Component = React.createClass

  # Helpers
  # 
  # gatherSomething: ->

  # Handlers
  # 
  handlePlaceholderClick: (event) ->
    console.log 'handlePlaceholderClick'

  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->

  # Component Specifications
  # 
  # getDefaultProps: ->
  # getInitialState: ->

  render: ->
    <article className="editor post">
      <section className="placeholder">
        <figure onClick={@handlePlaceholderClick}>
          <i className="fa fa-plus" />
        </figure>
      </section>
    </article>

# Exports
# 
module.exports = Component
