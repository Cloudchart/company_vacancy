# @cjsx React.DOM

Checkbox = require('components/form/checkbox')


Toggle = React.createClass

  displayName: 'Toggle'

  # Component Specifications
  # 
  propTypes:
    onText:           React.PropTypes.string.isRequired
    offText:          React.PropTypes.string.isRequired

  # TODO rewrite in 0.12
  render: ->
    props = _.extend @props,
              children:
                <span>
                  <span className="off">{ @props.offText }</span>
                  <i></i>
                  <span className="on">{ @props.onText }</span>
                </span>

    Checkbox(props)
    

# Exports
# 
module.exports = Toggle
