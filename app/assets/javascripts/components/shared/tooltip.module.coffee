# @cjsx React.DOM

# Exports
#
module.exports = React.createClass

  displayName: 'Tooltip'

  propTypes:
    className:      React.PropTypes.string
    element:        React.PropTypes.component.isRequired
    tooltipContent: React.PropTypes.any.isRequired

  render: ->
    <span className = "tooltip-wrapper #{@props.className}">
      { @props.element }
      <span className='tooltip'>
        { @props.tooltipContent }
      </span>
    </span>
