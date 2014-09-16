# Imports
#
tag = React.DOM


# Main
#
Component = React.createClass


  render: ->
    (tag.table {
      style:
        border: '1px solid #ccc'
    },
      (tag.thead {
      },
        (tag.tr {
        },
          (tag.td {}, 'User')
          (tag.td {}, 'Role')
          (tag.td {}, 'Action')
        )
      )
    )


# Exports
#
module.exports = Component
