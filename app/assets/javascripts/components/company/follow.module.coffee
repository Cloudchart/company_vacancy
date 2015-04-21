# Imports
# 
tag = React.DOM

CompanyActions = require('actions/company')
CompanyStore = require('stores/company')

# Main Component
# 
MainComponent = React.createClass

  # Helpers
  # 
  # gatherSomething: ->

  # Handlers
  # 
  handleFollowClick: (event) ->
    event.preventDefault()

    if @props.is_followed
      CompanyActions.unfollow(@props.uuid)
    else
      CompanyActions.follow(@props.uuid)

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
    (tag.button { 
      className: 'orgpad'
      disabled: /follow|unfollow/.test(CompanyStore.getSync(@props.uuid))
      onClick: @handleFollowClick
    },
      if @props.is_followed then 'Unfollow' else 'Follow'
    )

# Exports
# 
module.exports = MainComponent
