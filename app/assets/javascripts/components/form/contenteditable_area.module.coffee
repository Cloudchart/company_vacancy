# @cjsx React.DOM

# Imports
#
tag = React.DOM

sanitize = require('utils/contenteditable_sanitizer')


# Main
#
Component = React.createClass

  displayName: "ContenteditableArea"

  # Component Specifications
  # 
  propTypes:
    onChange:     React.PropTypes.func
    onBlur:       React.PropTypes.func
    onInput:      React.PropTypes.func
    onFocus:      React.PropTypes.func
    placeholder:  React.PropTypes.string
    readOnly:     React.PropTypes.bool
    value:        React.PropTypes.string

  getDefaultProps: ->
    onBlur: ->
    onChange: ->
    onFocus: ->
    onInput: ->

  getInitialState: ->
    content: @props.value

  # Handlers
  #
  handleBlur: (event) ->
    content = sanitize(event.target)
    @props.onChange(content) unless content is @props.value
    @props.onBlur(content)
    
    @setState
      content: content

  handleFocus: (event) ->
    content = sanitize(event.target)
    @props.onFocus(content)
  
  handleInput: (event) ->
    content = sanitize(event.target)
    @props.onInput(content)
    @getDOMNode().innerHTML = '' if content.length == 0

  handleKeyDown: (event) ->
    event.preventDefault() if event.key == 'Enter' and @getDOMNode().innerHTML == ''

  
  # Lifecycle Methods
  # 
  componentWillReceiveProps: (nextProps) ->
    @setState
      content: nextProps.value

  render: ->
    return null if @props.readOnly and !@props.value

    <div
      contentEditable = { !@props.readOnly }
      dangerouslySetInnerHTML = { __html: @state.content }
      data-placeholder = { @props.placeholder }
      onBlur = { @handleBlur }
      onFocus = { @handleFocus }
      onInput = { @handleInput }
      onKeyDown = { @handleKeyDown }
    />


# Exports
#
module.exports = Component
