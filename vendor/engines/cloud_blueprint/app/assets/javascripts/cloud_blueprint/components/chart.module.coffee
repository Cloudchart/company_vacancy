# Imports
#
tag = React.DOM


# Main
#
Component = React.createClass


  render: ->
    (tag.div {
      style:
        '-webkit-flex': '1 1'
    },
      'Chart goes here'
    )


# Exports
#
module.exports = Component
