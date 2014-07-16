##= require module
##= require react
##= require_tree ./chart_preview

# Imports
#
tag                     = React.DOM
Layout                  = cc.require('blueprint/react/chart-preview/layout/chart')
NodesContainerComponent = cc.require('blueprint/react/chart-preview/nodes-container')


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
    
    nodesContainerNode    = nodesContainer.getDOMNode()
    nodesContainerBounds  = nodesContainerNode.getBoundingClientRect()

    width           = Math.max(nodesContainerBounds.width,  layout.bounds.width   + @props.horizontal_padding * 2)
    height          = Math.max(nodesContainerBounds.height, layout.bounds.height  + @props.vertical_padding   * 2)

    nodesContainerNode.style.width  = width   + 'px'
    nodesContainerNode.style.height = height  + 'px'
    
    xOffset         = width / 2 + @props.horizontal_padding
    yOffset         = @props.vertical_padding
    
    Object.keys(nodes).forEach (uuid) ->
      position = layout.positions[uuid]

      nodes[uuid].position
        x:  position.x + xOffset
        y:  position.y + yOffset

    @setState
      should_recalculate_layout:  false
  

  componentWillMount: ->
    @load()
  
  
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
      className: 'blueprint-chart-preview-container'
    },
      (NodesContainerComponent {
        ref:      'nodes-container'
        scale:    @props.scale
        nodes:    @state.nodes
        width:    @state.width
        height:   @state.height
        url:      "/charts/#{@props.id}"
      },
        (tag.svg {
          ref: 'links-container'
        })
      )
    )


# Exports
#
cc.module('blueprint/react/chart-preview').exports = MainComponent
