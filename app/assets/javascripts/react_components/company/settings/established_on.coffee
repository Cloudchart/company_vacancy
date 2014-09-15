##= require cloud_blueprint/components/inputs/date_input.module

# Imports
# 
tag = React.DOM

DateInputComponent = require('cloud_blueprint/components/inputs/date_input')

# Main Component
# 
MainComponent = React.createClass


  # Helpers
  # 
  # gatherSomething: ->


  # Events
  # 
  onChange: (value) ->
    @props.onChange({ target: { value: value } })


  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillUnmount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->


  # Component Specifications
  # 
  # getDefaultProps: ->
  # getInitialState: ->

  render: ->
    (tag.div { className: 'profile-item' },
      (tag.div { className: 'content field' },
        (tag.label { htmlFor: 'established_on' }, 'Established on')

        (tag.div { className: 'spacer' })

        (DateInputComponent {
          id: 'established_on'
          name: 'established_on'
          date: if @props.value then new Date @props.value else ''
          placeholder: 'Type date'
          onChange: @onChange
        })
      )
    )    


# Exports
# 
cc.module('react/company/settings/established_on').exports = MainComponent
