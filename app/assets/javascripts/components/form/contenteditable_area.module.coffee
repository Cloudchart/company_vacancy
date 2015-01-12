# @cjsx React.DOM

# Imports
#
tag = React.DOM

sanitize = require('utils/contenteditable_sanitizer')


# Main
#
Component = React.createClass


  handleBlur: (event) ->    
    @props.onChange(sanitize(event.target)) if @props.onChange instanceof Function
  
  
  handleInput: (event) ->
    content = sanitize(event.target)
    @getDOMNode().innerHTML = '' if content.length == 0


  handleKeyDown: (event) ->
    event.preventDefault() if event.key == 'Enter' and @getDOMNode().innerHTML == ''


  render: ->
    return null if @props.readOnly and !@props.value

    <div
      contentEditable = { !@props.readOnly }
      dangerouslySetInnerHTML = { __html: @props.value }
      data-placeholder = { @props.placeholder }
      onBlur = { @handleBlur }
      onInput = { @handleInput }
      onKeyDown = { @handleKeyDown }
    />


# Exports
#
module.exports = Component
