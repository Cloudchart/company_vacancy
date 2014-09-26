# Imports
#
tag = React.DOM


# Main
#
Component = React.createClass


  render: ->
    (tag.article {
      className: 'company-2_0'
    },
      'New company article'
    )


# Exports
#
module.exports = Component
