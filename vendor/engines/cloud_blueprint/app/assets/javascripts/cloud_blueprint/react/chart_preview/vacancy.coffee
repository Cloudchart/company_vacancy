# Imports
#
tag = React.DOM


# Main Component
#
MainComponent = React.createClass

  render: ->
    (tag.li {
      className: 'vacancy'
    },
      @props.name
    )


# Exports
#
cc.module('blueprint/react/chart-preview/vacancy').exports = MainComponent