# Expose
#
tag = React.DOM


# Default block component
#
DefaultBlockComponent = React.createClass

  render: ->
    (tag.div { className: 'default' }, @props.identity_type)


# Block component
#
Component = React.createClass

  render: ->
    blockComponentClass = switch @props.identity_type
      when 'Paragraph'  then cc.react.editor.blocks.Paragraph
      when 'BlockImage' then cc.react.editor.blocks.BlockImage
      else DefaultBlockComponent
    
    (tag.div { className: 'section-block' },
      @transferPropsTo(blockComponentClass {})
    )


# Expose
#
cc.react.editor.blocks.Main = Component
