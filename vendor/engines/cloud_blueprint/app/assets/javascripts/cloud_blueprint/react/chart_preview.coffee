##= require module
##= require react
##= require_tree ./chart_preview

# Imports
#
tag                     = React.DOM
Layout                  = cc.require('blueprint/react/chart-preview/layout/chart')
NodesContainerComponent = cc.require('blueprint/react/chart-preview/nodes-container')
LinksContainerComponent = cc.require('blueprint/react/chart-preview/links-container')


# Main Component
#
MainComponent = React.createClass


  onLoadDone: (json) ->
    @setState
      loading:                    false
      should_recalculate_layout:  true
      nodes:                      json.nodes
  
  
  onLoadFail: ->
    console.warn "Fail: Chart preview loading."
    @setState
      loading: false


  load: ->
    @setState
      loading: true
    
    $.ajax
      url:      "/charts/#{@props.id}/preview"
      type:     "GET"
      dataType: "JSON"
    .done @onLoadDone
    .fail @onLoadFail
  
  
  calculateLayout: ->
    nodesContainer  = @refs['nodes-container']
    linksContainer  = @refs['links-container']

    nodes           = nodesContainer.refs
    links           = linksContainer.refs

    layout          = Layout(nodes)
    
    nodeBounds            = @getDOMNode().getBoundingClientRect()
    nodeStyle             = window.getComputedStyle(@getDOMNode())
    nodesContainerNode    = nodesContainer.getDOMNode()
    nodesContainerBounds  = nodesContainerNode.getBoundingClientRect()
    
    hBorders  = parseFloat(nodeStyle.borderLeftWidth)  + parseFloat(nodeStyle.borderRightWidth)
    vBorders  = parseFloat(nodeStyle.borderTopWidth)   + parseFloat(nodeStyle.borderBottomWidth)

    width     = Math.max(nodeBounds.width   - hBorders, layout.bounds.width   + @props.horizontal_padding * 2)
    height    = Math.max(nodeBounds.height  - vBorders, layout.bounds.height  + @props.vertical_padding   * 2)

    xOffset   = width / 2 + @props.horizontal_padding
    yOffset   = @props.vertical_padding

    nodesContainerNode.style.width  = width   + 'px'
    nodesContainerNode.style.height = height  + 'px'
    
    
    Object.keys(nodes).forEach (uuid) ->
      position = layout.positions[uuid]

      nodes[uuid].position
        x:  position.x + xOffset
        y:  position.y + yOffset
    

    Object.keys(links).forEach (uuid) ->
      position = layout.positions[uuid]
      
      links[uuid].position
        from:
          x: position.connectFrom.x + xOffset
          y: position.connectFrom.y + yOffset
        to:
          x: (position.connectTo.x + xOffset if position.connectTo)
          y: (position.connectTo.y + yOffset if position.connectTo)


    @setState
      should_recalculate_layout:  false
  
  
  onResize: (event) ->
    # Process resize event
  

  componentWillMount: ->
    @load()
    window.addEventListener('resize', @onResize)
  
  
  componentDidUpdate: ->
    @calculateLayout() if @state.should_recalculate_layout
  
  
  getDefaultProps: ->
    scale:                1
    horizontal_padding:   20
    vertical_padding:     20
  
  
  getInitialState: ->
    loading:  false
    nodes:    []
    width:    null
    height:   null


  render: ->
    (tag.div {
      className:  'blueprint-chart-preview-container'
      onResize:   @onResize
    },
      (NodesContainerComponent {
        ref:      'nodes-container'
        scale:    @props.scale
        nodes:    @state.nodes
        width:    @state.width
        height:   @state.height
        url:      "/charts/#{@props.id}"
      },
        (LinksContainerComponent {
          ref:    'links-container'
          nodes:  @state.nodes
        })
      )
    )


# Exports
#
cc.module('blueprint/react/chart-preview').exports = MainComponent
