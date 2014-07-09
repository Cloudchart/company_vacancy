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
    event.dataTransfer.setData('identity-type', @props.type)
  
  
  render: ->
    (tag.li {
      key:              @props.type
      className:        'editor-sidebar-blocks-item'
      'data-draggable': 'on'
    }, 
      (tag.i { className: "fa #{@props.icon}" })
      (tag.span {}, @props.title)
    )


#
#
#

BlocksSidebarComponent = React.createClass

  gatherBlocks: ->
    @props.blocks.map (block_props) ->
      block_props.key = block_props.type
      (BlockComponent block_props)

  render: ->
    (tag.aside { className: 'sidebar-blocks' },
      (TitleComponent {})
      (tag.ul {}, @gatherBlocks())
    )

#
#
#

@cc.react.editor.BlocksSidebarComponent = BlocksSidebarComponent
