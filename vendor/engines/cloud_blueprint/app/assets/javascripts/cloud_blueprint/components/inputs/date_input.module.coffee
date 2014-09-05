# Imports
#
tag = React.DOM


# Functions
#
formatDate = (date, format = 'll') ->
  if date instanceof Date then moment(date).format(format) else ''


getStateFromDate = (date) ->
  date:   date
  value:  formatDate(date)


# Main Component
#
Component = React.createClass


  onBlur: (event) ->
    date = if @state.value == '' then null else @state.date || @props.date
    @setState _.extend getStateFromDate(date), { shouldPropagate: true }


  onChange: (event) ->
    value = event.target.value

    @setState
      value:            value 
      date:             Date.parse(value)
      shouldPropagate:  false
  
  
  componentWillReceiveProps: (nextProps) ->
    @setState _.extend getStateFromDate(nextProps.date), { shouldPropagate: false }
  
  
  componentDidUpdate: (prevProps, prevState) ->
    if @state.shouldPropagate
      @props.onChange(@state.date) if @props.onChange instanceof Function


  getInitialState: ->
    getStateFromDate(@props.date)


  render: ->
    className = [@props.className] ; className.push('invalid') unless @state.date or @state.value == ''

    @transferPropsTo(
      (tag.input {
        className:  className.join(' ')
        value:      @state.value
        onChange:   @onChange
        onBlur:     @onBlur
      })
    )


# Exports
#
module.exports = Component
