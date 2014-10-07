# Imports
#
tag = React.DOM

sanitize = require('utils/contenteditable_sanitizer')


# Main
#
Component = React.createClass


  onBlur: (event) ->
    @props.onChange(sanitize(event.target)) if @props.onChange instanceof Function
  
  
  onInput: (event) ->
    content = sanitize(event.target)
    @getDOMNode().innerHTML = '' if content.length == 0
  
  
  getInitialState: ->
    value:    @props.value


  render: ->
    (tag.div {
      contentEditable:          !@props.readOnly
      dangerouslySetInnerHTML:  { __html: @props.value }
      'data-placeholder':       @props.placeholder
      onBlur:                   @onBlur
      onInput:                  @onInput
    })


# Exports
#
module.exports = Component
