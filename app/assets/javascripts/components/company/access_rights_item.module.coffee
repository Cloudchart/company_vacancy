module.exports = React.createClass

  render: ->
    (tag.tr {
      className: 'access-right'
    },
    
      (tag.td {
        className: 'name'
      },
        @props.user.full_name
      )
      
      (tag.td {
        className: 'role'
      },
        @props.role.value
      )
      
      (tag.td {
        className: 'actions'
      },
        '-'
      )
    
    )
