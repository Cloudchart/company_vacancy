# @cjsx React.DOM


# Utils
#
cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'InsightSaveButton'

  # Specification
  #

  getDefaultProps: ->
    sync:   false


  # Main Render
  #

  render: ->

    className = cx
      'save':     true

    iconClassName = cx
      'fa':         true
      'fa-share':   true
      'fa-spin':    @props.sync   == true

    <li className={ className } style={ opacity: .25 }>
      <i className={ iconClassName } onClick={ @props.onClick } />
    </li>
