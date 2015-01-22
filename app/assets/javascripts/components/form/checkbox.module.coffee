# @cjsx React.DOM

# SomeComponent = require('')

# Main Component
# 
MainComponent = React.createClass

  # Component Specifications
  # 
  propTypes:
    checked:     React.PropTypes.bool
    customClass: React.PropTypes.string
    onChange:    React.PropTypes.func
    iconClass:   React.PropTypes.string


  getDefaultProps: ->
    customClass: ''
    iconClass:   ''
    onChange:    ->

  getInitialState: ->
    checked: @props.checked

  # Handlers
  # 
  onChange: (event) ->
    @props.onChange(event.target.checked)

  # Lifecycle Methods
  # 
  componentWillReceiveProps: (nextProps) ->
    @setState(checked: nextProps.checked)

  render: ->
    customClass = "checkbox cc #{@props.customClass}".trim()

    if @props.iconClass
      customClass += " with-icon"

    <label className={ customClass }>
      <input type="checkbox" checked={ @state.checked } onChange={ @onChange } />
      {
        <i className={ "fa #{@props.iconClass}" }></i> if @props.iconClass != ''
      }
    </label>
    

# Exports
# 
module.exports = MainComponent
