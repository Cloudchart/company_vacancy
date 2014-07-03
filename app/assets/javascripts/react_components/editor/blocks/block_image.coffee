# Expose tags
#
tag = React.DOM


# Paragraph Block component
#

Component = React.createClass

  render: ->
    (tag.div { className: 'image' },
      "Image Block"
    )


# Expose
#
cc.react.editor.blocks.BlockImage = Component