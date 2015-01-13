# @cjsx React.DOM

# Imports
#
tag = React.DOM

sanitize = require('utils/contenteditable_sanitizer')


# Main
#
Component = React.createClass


  handleBlur: (event) ->
    content = sanitize(event.target)
    @props.onChange(content) if @props.onChange instanceof Function
    
    @setState
      content: content
  
  
  handleInput: (event) ->
    content = sanitize(event.target)
    @getDOMNode().innerHTML = '' if content.length == 0


  handleKeyDown: (event) ->
    event.preventDefault() if event.key == 'Enter' and @getDOMNode().innerHTML == ''
  
  
  componentWillReceiveProps: (nextProps) ->
    @setState
      content: nextProps.value
  

  getInitialState: ->
    content: @props.value


  render: ->
    return null if @props.readOnly and !@props.value

    <div
      contentEditable = { !@props.readOnly }
      dangerouslySetInnerHTML = { __html: @state.content }
      data-placeholder = { @props.placeholder }
      onBlur = { @handleBlur }
      onInput = { @handleInput }
      onKeyDown = { @handleKeyDown }
    />


# Exports
#
module.exports = Component
