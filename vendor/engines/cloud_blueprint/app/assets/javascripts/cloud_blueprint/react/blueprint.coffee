# Shortcuts
#
tag = React.DOM


#
#
#


Blueprint = React.createClass

  render: ->
    (tag.article { className: 'chart' },
      @props.children
      (tag.section { className: 'chart' },
        (tag.svg {})
      )
    )

#
#
#

_.extend @cc.blueprint.react,
  Blueprint: Blueprint
