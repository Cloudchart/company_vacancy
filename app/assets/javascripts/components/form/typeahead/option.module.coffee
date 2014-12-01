# @cjsx React.DOM

cx = React.addons.classSet

TypeaheadOption = React.createClass
  propTypes:
    onClick: React.PropTypes.func
    onHover: React.PropTypes.func

  onClick: (e) ->
    @props.onClick()

  getDefaultProps: ->
    onClick: -> return false

  getInitialState: ->
    hover: false

  render: ->
    <li className={cx(hover: @props.hover)}
        onClick={@props.onClick}
        onMouseEnter={@props.onHover}>
      { this.props.children }
    </li>

module.exports = TypeaheadOption