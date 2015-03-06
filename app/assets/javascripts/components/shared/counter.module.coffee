# @cjsx React.DOM
#

cx = React.addons.classSet

module.exports = React.createClass
  
  displayName: "Counter"

  # Component Specifications
  # 
  propTypes:
    count:       React.PropTypes.number
    visible:     React.PropTypes.bool

  getInitialState: ->
    visible: true

  render: ->
    if @props.visible
      <aside className={cx(counter: true, negative: @props.count < 0)}>
        { @props.count }
      </aside>
    else
      null
