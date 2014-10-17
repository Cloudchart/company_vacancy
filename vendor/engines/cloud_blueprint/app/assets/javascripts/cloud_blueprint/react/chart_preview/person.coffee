###
  Used in:

  cloud_blueprint/react/chart_preview/node
###

# Imports
#
tag = React.DOM


# Main Component
#
MainComponent = React.createClass

  render: ->
    (tag.li {
      className: 'person'
    },
      [@props.first_name, @props.last_name].filter((part) -> part).join(' ')
    )


# Exports
#
cc.module('blueprint/react/chart-preview/person').exports = MainComponent
