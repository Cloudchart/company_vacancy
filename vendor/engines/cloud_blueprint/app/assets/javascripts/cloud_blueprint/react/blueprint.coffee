##= require_self
##= require_tree ./blueprint


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
    )


#
#
#

_.extend @cc.blueprint.react,
  Blueprint: Blueprint
