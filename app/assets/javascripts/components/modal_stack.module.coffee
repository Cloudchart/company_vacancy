# @cjsx React.DOM

# Imports
#
tag = React.DOM

CloudFlux     = require('cloud_flux')
GlobalState   = require('global_state/state')


EmptyFunction = ->


# ModalStackCursor
#
ModalStackCursor  = GlobalState.cursor(['meta', 'modal', 'stack'])
EmptyModalStack   = Immutable.List()

ModalStackCursor.update -> EmptyModalStack


# Modal Stack Item
#
ModalStackItem = React.createClass

  displayName: 'ModalStackItem'


  handleClick: (event) ->
    return unless event.target == @getDOMNode()
    return unless @state.isMouseDownOnOverlay
    @props.onClick()

    @setState(isMouseDownOnOverlay: false)

  handleMouseDown: (event) ->
    if event.target == @getDOMNode()
      @setState(isMouseDownOnOverlay: true)

  componentWillMount: ->
    @props.beforeShow()


  componentDidMount: ->
    @props.afterShow()


  componentWillUnmount: ->
    @props.beforeHide()


  getDefaultProps: ->
    beforeShow:   EmptyFunction
    afterShow:    EmptyFunction
    beforeHide:   EmptyFunction
    onClick:      EmptyFunction

  getInitialState: ->
    isMouseDownOnOverlay: false

  render: ->
    <li className="modal-stack-item modal-container" onMouseDown={ @handleMouseDown } onClick={ @handleClick } style={ zIndex: @props.index }>
      { @props.children }
    </li>


# Modal Stack
#
ModalStack = React.createClass

  displayName: 'ModalStack'


  mixins: [GlobalState.mixin]


  statics:

    show: (element, options = {})   ->
      ModalStackCursor.update (data) ->
        data.push
          element: element
          options: options

    hide: ->
      ModalStackCursor.update (data) -> data.pop()

    close: ->
      ModalStackCursor.update (data) -> data.pop()


  handleEscape: (event) ->
    return unless event.keyCode == 27
    @constructor.hide()


  handleClick: (event) ->
    @constructor.hide()


  componentDidMount: ->
    window.addEventListener('keydown', @handleEscape)


  componentWillUnmount: ->
    window.removeEventListener('keydown', @handleEscape)


  componentDidUpdate: ->
    document.body.style.overflow = if @props.cursor.count() == 0 then 'scroll' else 'hidden'


  getDefaultProps: ->
    cursor: ModalStackCursor


  renderComponents: ->
    @props.cursor.map (item, index) =>
      <ModalStackItem {...item.options}
        key     = { index }
        index   = { index }
        onClick = { @handleClick }
      >
        { item.element }
      </ModalStackItem>


  render: ->
    return null if @props.cursor.count() == 0

    <ul className="modal-stack modal-overlay">
      { @renderComponents().toArray() }
    </ul>


# Exports
#
module.exports = ModalStack
