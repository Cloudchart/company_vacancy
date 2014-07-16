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
      @props.first_name
      " "
      (tag.strong {}, @props.last_name)
    )


# Exports
#
cc.module('blueprint/react/chart-preview/person').exports = MainComponent
