# Imports
# 
tag = React.DOM

# SomeComponent = cc.require('')

# Main Component
# 
MainComponent = React.createClass

  # Helpers
  # 
  # gatherSomething: ->

  # Events
  # 
  onChange: (event) ->
    @setState({ value: event.target.value })

  onBlur: (event) ->
    @props.onChange({ target: { value: @state.value }}) if @state.value != @props.value

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
  getInitialState: ->
    value: @props.value || ''

  render: ->
    (tag.div { className: 'profile-item' },
      (tag.div { className: 'content field' },
        (tag.label { htmlFor: 'tag_list' }, 'Tags')

        (tag.div { className: 'spacer' })

        (tag.input {
          id: 'tag_list'
          name: 'tag_list'
          placeholder: 'russia, entertainment, games'
          value: @state.value
          onChange: @onChange
          onBlur: @onBlur
        })
      )
    )

# Exports
# 
cc.module('react/company/settings/tag_list').exports = MainComponent
