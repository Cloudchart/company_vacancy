# @cjsx React.DOM


FuzzyDate = require('utils/fuzzy_date')


# Exports
#
module.exports = React.createClass


  displayName: 'FuzzyDate'
  
  
  handleChange: (event) ->
    @setState
      value: event.target.value
  
  
  handleKeyUp: (event) ->
    @getDOMNode().blur() if event.key == 'Enter'
  
  
  handleUpdate: ->
    return @props.onUpdate('', '') if @state.value is ''
    
    parts = Immutable.Seq(@state.value.split(/[^0-9a-z]/gi)).filter((v) -> !!v)
    date  = moment(Date.parse(@state.value))
    
    [from, till] = switch parts.count()
      when 2
        [date.clone().startOf('month'), date.clone().endOf('month')]
      when 3
        [date, date]
      else
        [null, null]
    
    if from and  till and from.isValid() and till.isValid()
      @props.onUpdate(from.format('YYYY-MM-DD'), till.format('YYYY-MM-DD'))
    else
      @setState({ error: true })
  
  
  getValueFromProps: (props) ->
    FuzzyDate.format(props.from, props.till)
  
  
  componentWillReceiveProps: (nextProps, nextState) ->
    @setState
      value: @getValueFromProps(nextProps)
  
  
  getDefaultProps: ->
    onUpdate: ->
  
  
  getInitialState: ->
    value: @getValueFromProps(@props)


  render: ->
    <input
      onBlur      = { @handleUpdate }
      onChange    = { @handleChange }
      onKeyUp     = { @handleKeyUp  }
      placeholder = { moment().format('ll') }
      type        = "text"
      value       = { @state.value }
    />
