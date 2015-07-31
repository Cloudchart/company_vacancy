# @cjsx React.DOM


cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'StarInsightButton'

  # Specification
  #

  getDefaultProps: ->
    active: false
    sync:   false


  # Main Render
  #

  render: ->

    className = cx
      'fa':         true
      'fa-star':    @props.active == true
      'fa-star-o':  @props.active == false
      'fa-spin':    @props.sync   == true

    <li className="star">
      <i className={ className } onClick={ @props.onClick } />
    </li>
