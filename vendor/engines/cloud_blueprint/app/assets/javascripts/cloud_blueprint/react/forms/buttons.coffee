# Shortcuts
#
tag = React.DOM

#
#
#


Buttons = React.createClass

  render: ->
    (tag.section { className: 'buttons' },
      if @props.model.is_persisted()
        (tag.a {
          href:       '#'
          className:  'alert blueprint-button'
          onClick:    @props.onDelete
        },
          (tag.i { className: 'fa fa-times' })
          " "
          "Delete"
        )
      (tag.div { className: 'spacer' })
      (tag.button { className: 'blueprint' },
        (tag.i { className: 'fa fa-check' })
        " "
        ["Create", "Update"][~~@props.model.is_persisted()]
      )
    )


#
#
#

_.extend @cc.blueprint.react.forms,
  Buttons: Buttons
