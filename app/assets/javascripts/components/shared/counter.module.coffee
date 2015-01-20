# @cjsx React.DOM
#

cx = React.addons.classSet

module.exports = React.createClass
  
  displayName: "Counter"

  # Component Specifications
  # 
  propTypes:
    count:       React.PropTypes.number

  render: ->
    <aside className={cx(counter: true, negative: @props.count < 0)}>
      { @props.count }
    </aside>
