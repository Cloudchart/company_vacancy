# Shortcuts
#
tag = React.DOM


# Dom manipulations
#
DOM =
  
  getDimensions: ->
    @__dimensions ||= @getDOMNode().getBoundingClientRect()
  
  
  getHeight: ->
    @getDimensions().height
  

  getWidth: ->
    @getDimensions().width



# Node drag element
#
element_for_drag = ->
  element = document.createElement('div')
  
  element.style.backgroundColor = '#000'
  element.style.borderRadius    = '5px'
  element.style.height          = '10px'
  element.style.position        = 'absolute'
  element.style.width           = '10px'
  
  document.body.appendChild(element)

  element



# Events
#
Events =
  
  
  onDragStart: (event) ->
    @__element_for_drag = element_for_drag()

    event.dataTransfer.setData('node', @props.key)
    event.dataTransfer.setDragImage(@__element_for_drag, 5, 5)

    event.dataTransfer.effectAllowed = 'link'
    

  onDragEnd: (event) ->
    @__element_for_drag.parentNode.removeChild(@__element_for_drag) if @__element_for_drag
    @__element_for_drag = null
  
  
  
  onDragOver: (event) ->
  
  
  onClick: (event) ->
    return if @props.model.is_synchronizing()
    
    cc.ui.modal null,
      after_show:   @renderForm
      before_close: @hideForm
  
  
  renderForm: (container) ->
    React.renderComponent(cc.blueprint.react.forms.Node({ model: @props.model, colors: @props.colors }), container)


  hideForm: (container) ->
    React.unmountComponentAtNode(container)


#
#
#

Node = React.createClass

  
  mixins: [
    DOM
    Events
  ]

  
  getDefaultProps: ->
    model:          cc.blueprint.models.Node.get(@props.key)
    can_be_edited:  false
  

  componentDidUpdate: (prevProps, prevState) ->
    @__dimensions = null

    element       = @getDOMNode()

    element.style.left  = @state.left - @getWidth() / 2 + 'px'
    element.style.top   = @state.top - @getHeight() / 2 + 'px'


  setPosition: (position) ->
    @setState
      left: position.left
      top:  position.top


  render: ->
    (tag.div {
      className:    'node'
      onClick:      @onClick      if @props.can_be_edited
      onDragStart:  @onDragStart  if @props.can_be_edited
      onDragEnd:    @onDragEnd    if @props.can_be_edited
      onDragOver:   @onDragOver   if @props.can_be_edited
      draggable:                     @props.can_be_edited
      style: 
        backgroundColor: @props.colors[@props.model.color_index]
    },
      (tag.div { className: 'flag' }) if false # should contain vacancies
      (tag.h2 {}, @props.model.title)
    )

#
#
#

_.extend @cc.blueprint.react.Blueprint,
  Node: Node
