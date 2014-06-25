# Shortcuts
#
tag = React.DOM


#
#
#

NodeVacancy = React.createClass

  render: ->
    (tag.li { className: 'vacancy' },
      @props.model.name,
    )

#
#
#

_.extend @cc.blueprint.react.Blueprint,
  NodeVacancy: NodeVacancy
