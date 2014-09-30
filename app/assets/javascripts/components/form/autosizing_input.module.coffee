# Imports
#
tag = React.DOM


# Main
#
Component = React.createClass


  componentDidMount: ->
    inputNode = @refs['input'].getDOMNode()
    sizerNode = @refs['sizer'].getDOMNode()
    
    inputNodeStyle = window.getComputedStyle(inputNode)
    
    _.each ['border-left', 'border-right', 'font-size', 'font-weight', 'padding-left', 'padding-right'], (name) ->
      sizerNode.style[name] = inputNodeStyle[name]
  
  
  render: ->
    (tag.div {
      className:  'autosizing-input-container'
      style:
        display:  'inline-block'
        maxWidth: '100%'
        width:    'auto'
    },
    
      (tag.div {
        ref:          'sizer'
        style:
          height:     0
          overflow:   'hidden'
          visibility: 'hidden'
          whiteSpace: 'pre'
      },
        @props.value || @props.placeholder
      )

      @transferPropsTo(
        (tag.input {
          ref:        'input'
          size:       1
          style:
            width:    '100%'
        })
      )
    )


# Exports
#
module.exports = Component
