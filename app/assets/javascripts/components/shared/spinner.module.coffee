# @cjsx React.DOM

cx = React.addons.classSet

# Main Component
#
Component = React.createClass

  propTypes:
    className: React.PropTypes.string

  getDefaultProps: ->
    className: ""

  render: ->
    className = ("spinner " + @props.className).trim()

    <div className={className}>
      <i className="fa fa-spinner fa-spin"></i>
    </div>


# Exports
#
module.exports = Component
