# Imports
#
tag = React.DOM


# Functions
#
validateValue = (value) ->
  floatValue = parseFloat(value)
  value.length == 0 or (_.isNumber(floatValue) and floatValue >= 0 and floatValue <= 100)


# Main
#
Component = React.createClass


  mixins: [
    React.addons.LinkedStateMixin
  ]
  
  
  onBlur: (event) ->
  
  
  onChange: (event) ->
    @setState
      value:    event.target.value
      isValid:  validateValue(event.target.value)


  componentWillReceiveProps: (nextProps) ->
    @setState
      value: nextProps.value
  
  
  getInitialState: ->
    value:    @props.value
    isValid:  true


  render: ->
    @transferPropsTo(
      (tag.input {
        className:  'invalid' unless @state.isValid
        value:      @state.value
        onChange:   @onChange
        onBlur:     @onBlur
      })
    )


# Exports
#
module.exports = Component
