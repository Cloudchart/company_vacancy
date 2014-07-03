# Expose tags
#
tag = React.DOM


# Paragraph Block component
#

Component = React.createClass

  render: ->
    (tag.div { className: 'person' },
      "Person"
    )


# Expose
#
cc.react.editor.blocks.Person = Component
