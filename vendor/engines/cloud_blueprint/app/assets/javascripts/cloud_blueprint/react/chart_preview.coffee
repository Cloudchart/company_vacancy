##= require module
##= require react
##= require_tree ./chart_preview

# Imports
#
tag                     = React.DOM
NodesContainerComponent = cc.require('blueprint/react/chart-preview/nodes-container')


# Main Component
#
MainComponent = React.createClass


  onLoadDone: (json) ->
    @setState
      loading:  false
      nodes:    json.nodes
  
  
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
  
  
  componentWillMount: ->
    @load()
  
  
  getDefaultProps: ->
    scale: 1
  
  
  getInitialState: ->
    loading:  false
    nodes:    []


  render: ->
    (tag.div {
      className: 'blueprint-chart-preview-container'
    },
      (NodesContainerComponent {
        ref:    'nodes-container'
        scale:  @props.scale
        nodes:  @state.nodes
        url:    "/charts/#{@props.id}"
      },
        (tag.svg {
          ref: 'relations-container'
        })
      )
    )


# Exports
#
cc.module('blueprint/react/chart-preview').exports = MainComponent
