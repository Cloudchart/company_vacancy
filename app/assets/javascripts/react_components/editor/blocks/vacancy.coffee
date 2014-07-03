# Expose tags
#
tag = React.DOM


# Paragraph Block component
#

Component = React.createClass

  render: ->
    (tag.div { className: 'vacancy' },
      "Vacancy"
    )


# Expose
#
cc.react.editor.blocks.Vacancy = Component
