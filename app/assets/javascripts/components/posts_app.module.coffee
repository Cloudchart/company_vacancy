# @cjsx React.DOM

# Imports
# 
tag = React.DOM
cx = React.addons.classSet

Timeline = require('components/company/timeline')

# Main
# 
MainComponent = React.createClass

  # mixins: []
  # propTypes: {}
  # displayName: 'Meaningful name'

  # Helpers
  # 
  # gatherSomething: ->

  # Handlers
  # 
  # handleThingClick: (event) ->

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
  # getStateFromProps: ->
  # getInitialState: ->

  render: ->
    <div className="wrapper">
      <Timeline 
        company_id = { @props.company_id }
        readOnly = { true }
      />
    </div>


# Exports
# 
module.exports = MainComponent
