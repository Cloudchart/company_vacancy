# @cjsx React.DOM
#

module.exports = React.createClass
  
  displayName: "Wrapper"

  # Component Specifications
  # 
  propTypes:
    className: React.PropTypes.string
    isWrapped: React.PropTypes.bool

  getDefaultProps: ->
    className: ""
    isWrapped: true

  render: ->
    className = "wrapper #{@props.className}".trim()

    if @props.isWrapped
      <div className={ className }>
        { @props.children }
      </div>
    else
      @props.children[0]