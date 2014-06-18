# Shortcuts
#
tag = React.DOM


# Instances pool
#
instances = {}


# Position node
#
position = (node, left, top) ->
  element = node.getDOMNode()
  
  element.style.left  = left - node.getWidth() / 2 + 'px'
  element.style.top   = top - node.getHeight() / 2 + 'px'


# Move node
#
move = (node, prevState) ->
  unless prevState
    position(node, node.state.left, node.state.top)
    return
  
  duration  = 200
  start     = null
  
  tick = (timestamp) ->
    start     = timestamp unless start
    progress  = timestamp - start
    delta     = progress / duration
    delta     = 1 if delta > 1
    
    position node,
      prevState.left + (node.state.left - prevState.left) * delta,
      prevState.top + (node.state.top - prevState.top) * delta
    
    if progress <= duration then requestAnimationFrame(tick) else position(node, node.state.left, node.state.top)
  
  requestAnimationFrame(tick)


# Dom manipulations
#
DOM =
  
  getDimensions: ->
    @__dimensions ||= @getDOMNode().getBoundingClientRect()
  
  
  getHeight: ->
    @getDimensions().height
  

  getWidth: ->
    @getDimensions().width



# Events
#
Events =
  
  # On node click
  #
  onClick: (event) ->
    event.stopPropagation()
    return if @props.model.is_synchronizing()
    cc.ui.modal null, { after_show: @renderForm, before_close: @hideForm }
  
  
  # Render node form
  #
  renderForm: (container) ->
    React.renderComponent(cc.blueprint.react.forms.Node({ model: @props.model, colors: @props.colors }), container)


  # Close node form
  #
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
    model:            cc.blueprint.models.Node.get(@props.key)
    children_density: 25
    can_be_edited:    false
  
  
  componentDidMount: ->
    instances[@props.key] = @
  
  
  componentWillUnmount: ->
    delete instances[@props.key]
  

  componentDidUpdate: (prevProps, prevState) ->
    @__dimensions = null

    element       = @getDOMNode()
    
    move(@, prevState)

    #element.style.left  = @state.left - @getWidth() / 2 + 'px'
    #element.style.top   = @state.top - @getHeight() / 2 + 'px'


  setPosition: (position) ->
    @setState
      left: position.left
      top:  position.top


  render: ->
    (tag.div {
      className:                'node'
      onClick:                  @onClick      if @props.can_be_edited
      'data-id':                @props.key
      'data-behaviour':         'droppable'   if @props.can_be_edited
      style: 
        backgroundColor: @props.colors[@props.model.color_index]
        minWidth:         @props.children_density * @props.model.children.length
    },
      (tag.div { className: 'flag' }) if false # should contain vacancies
      (tag.h2 {}, @props.model.title)
    )

# Get instance from instance pool
#
Node.get = (key) -> instances[key]

#
#
#

_.extend @cc.blueprint.react.Blueprint,
  Node: Node
