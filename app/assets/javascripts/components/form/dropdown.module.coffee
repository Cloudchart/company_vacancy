# @cjsx React.DOM

# Main Component
#
Dropdown = React.createClass

  # Component Specifications
  #
  propTypes:
    customClass:   React.PropTypes.string
    emptyText:     React.PropTypes.string
    hasEmptyValue: React.PropTypes.bool
    iconClass:     React.PropTypes.string
    onChange:      React.PropTypes.func
    options:       React.PropTypes.object
    value:         React.PropTypes.string

  getDefaultProps: ->
    customClass:   ''
    hasEmptyValue: false
    iconClass:     "fa fa-angle-down"

  getInitialState: ->
    showEmptyValue: !@props.value || @props.value == ''
    value: @props.value

  # Helpers
  #
  gatherOptions: ->
    options = _.map @props.options, (text, value) =>
      <option key={value} value={value}>{ '' + text }</option>

    if @state.showEmptyValue && @props.hasEmptyValue
      options.unshift <option key='' value=''>{ @props.emptyText }</option>

    options

  # Handlers
  #
  onChange: (event) ->
    newValue = event.target.value

    if newValue
      @setState showEmptyValue: false

    @props.onChange(newValue)

  # Lifecycle Methods
  #
  componentWillReceiveProps: (nextProps) ->
    @setState(value: nextProps.value)

  render: ->
    <div className="select cc">
      <select className={ @props.customClass }
              onChange={ @onChange }
              value={ @state.value } >
        { @gatherOptions() }
      </select>
      <i className={ @props.iconClass }></i>
    </div>

# Exports
#
module.exports = Dropdown
