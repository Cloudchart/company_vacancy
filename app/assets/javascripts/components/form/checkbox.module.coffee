# @cjsx React.DOM

# SomeComponent = require('')

# Main Component
# 
MainComponent = React.createClass

  # Component Specifications
  # 
  propTypes:
    checked:          React.PropTypes.bool
    customClass:      React.PropTypes.string
    onChange:         React.PropTypes.func
    iconClass:        React.PropTypes.string
    iconCheckedClass: React.PropTypes.string


  getDefaultProps: ->
    customClass: ''
    iconClass:   ''
    onChange:    ->

  getInitialState: ->
    checked: @props.checked

  getCustomClass: ->
    customClass = "checkbox cc #{@props.customClass}".trim()

    if @state.checked
      customClass += " checked"

    customClass

  getIconClass: ->
    if @state.checked then @props.iconCheckedClass else @props.iconClass

  # Handlers
  # 
  onChange: (event) ->
    @props.onChange(event.target.checked)

  # Lifecycle Methods
  # 
  componentWillReceiveProps: (nextProps) ->
    @setState(checked: nextProps.checked)

  render: ->
    <label className={ @getCustomClass() }>
      {
        <i className={ "fa #{@getIconClass()}" }></i> if @props.iconClass != ''
      }
      <input type="checkbox" checked={ @state.checked } onChange={ @onChange } />
      { @props.children }
    </label>
    

# Exports
# 
module.exports = MainComponent
