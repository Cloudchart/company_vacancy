# Imports
#
tag = React.DOM


# Main
#
Component = React.createClass


  render: ->
    (tag.section {
      className: 'fresh'
    },
      (tag.i { className: 'fa fa-spin fa-spinner' })
    )


# Exports
#
module.exports = Component
