# Expose
#
tag = React.DOM


# Sidebar Block Component
#
SidebarBlockComponent = React.createClass


  mixins: [cc.react.mixins.Draggable]


  onCCDragStart: (event) ->
    event.dataTransfer.setData('block-type', @props.type)


  onCCDragMove: (event) ->
    @getDOMNode().classList.add('draggable')
  

  onCCDragEnd: (event) ->
    @getDOMNode().classList.remove('draggable')
  

  render: ->
    (tag.li {
      className:          'editor-sidebar-item'
      'data-draggable':   'on'
    },
      (tag.i { className: "fa #{@props.icon}" })
    )


# Main Component
#
MainComponent = React.createClass


  items: ->
    @props.blocks.map (block) ->
      block.key = block.type
      SidebarBlockComponent block
  
  
  componentDidMount: ->
    node = @getDOMNode()
    node.style.marginTop = - node.getBoundingClientRect().height / 2 + 'px'
  
  
  render: ->
    (tag.aside {
      className:  'sidebar'
    },
      (tag.ul {},
        @items()
      )
    )

# Expose
#
@cc.react.editor.SidebarComponent = MainComponent
