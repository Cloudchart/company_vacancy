# Imports
#
tag = cc.require('react/dom')


# Main Component
#
Component = React.createClass


  onChange: (event) ->
    @setState
      value:    event.target.value
      changed:  true
  
  
  onFocus: (event) ->
  
  
  onBlur: (event) ->
  
  
  onKeyUp: (event) ->
  

  componentWillReceiveProps: (nextProps) ->
    @setState({ changed: false })
  
  
  componentDidUpdate: (prevProps, prevState) ->
    if @props.onChange instanceof Function
      if prevState.value isnt @state.value and @state.changed == true
        @props.onChange({ target: { name: @props.name, value: @state.value }})


  getInitialState: ->
    value:    @props.value || ''
    changed:  false


  render: ->
    @transferPropsTo(
      (tag.input {
        value:    @state.value
        onFocus:  @onFocus
        onBlur:   @onBlur
        onChange: @onChange
        onKeyUp:  @onKeyUp
      })
    )


# Exports
#
cc.module('react/modals/input').exports = Component
