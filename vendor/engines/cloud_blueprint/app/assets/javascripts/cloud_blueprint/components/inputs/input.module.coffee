# Imports
#
tag = React.DOM


# Main Component
#
Component = React.createClass

  onChange: (event) ->
    value = event.target.value
    
    @setState({ value: value })
    
    @props.onChange(event) if @props.onChange
  
  
  onBlur: (event) ->
    @props.onBlur(event) if @props.onBlur
  
  
  componentWillReceiveProps: (nextProps) ->
    @setState({ value: nextProps.value })
  
  
  getInitialState: ->
    value:  @props.value
  

  render: ->
    @transferPropsTo(

      (tag.input {
        value:    @state.value
        onChange: @onChange
        onBlur:   @onBlur
      })

    )



# Exports
#
module.exports = Component
