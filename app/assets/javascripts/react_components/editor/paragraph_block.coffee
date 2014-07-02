# Expose tags
#
tag = React.DOM


# Paragraph Block component
#

ParagraphBlockComponent = React.createClass

  render: ->
    (tag.div { className: 'paragraph' },
      "Paragraph"
    )


# Expose
#
cc.react.editor.blocks.Paragraph = ParagraphBlockComponent