# Shortcuts
#
tag = React.DOM


#
#
#

NodePerson = React.createClass

  render: ->
    (tag.li { className: 'person' },
      @props.model.first_name,
      " ",
      (tag.strong {}, @props.model.last_name)
    )

#
#
#

_.extend @cc.blueprint.react.Blueprint,
  NodePerson: NodePerson
