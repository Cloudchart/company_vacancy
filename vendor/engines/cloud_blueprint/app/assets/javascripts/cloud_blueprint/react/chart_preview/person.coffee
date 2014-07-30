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
      @props.full_name
    )


# Exports
#
cc.module('blueprint/react/chart-preview/person').exports = MainComponent
