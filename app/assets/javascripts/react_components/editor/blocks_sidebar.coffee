#
#
tag = React.DOM


# Title Component
#
TitleComponent = React.createClass

  render: ->
    (tag.header {},
      "This is the editor. Drag to add "
      (tag.i { className: 'fa fa-arrow-left' })
    )


# Block Component
#
BlockComponent = React.createClass


  mixins: [cc.react.mixins.Draggable]
  
  
  onCCDragStart: (event) ->
    event.dataTransfer.setData('sidebar-blocks-item', @props.key)
  
  
  render: ->
    (tag.li {
      className: 'editor-sidebar-blocks-item'
      'data-draggable': 'on'
    }, 
      (tag.i { className: "fa #{@props.icon}" })
      @props.title
    )


#
#
#

BlocksSidebarComponent = React.createClass

  render: ->
    blocks = @props.blocks.map (props) -> BlockComponent(props)
    
    (tag.aside { className: 'sidebar-blocks' },
      TitleComponent()
      (tag.ul {},
        blocks
      )
    )

#
#
#

@cc.react.editor.BlocksSidebarComponent = BlocksSidebarComponent
