# @cjsx React.DOM
#

module.exports = React.createClass
  
  displayName: "FieldWrapper"

  # Component Specifications
  # 
  propTypes:
    className: React.PropTypes.string

  getDefaultProps: ->
    className: ""

  render: ->
    className = "editor-field-wrapper #{@props.className}".trim()

    <div className={ className }>
      { @props.children }
    </div>