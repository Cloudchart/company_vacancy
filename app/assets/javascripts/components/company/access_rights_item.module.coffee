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
        @props.access_right.role
      )
      
      (tag.td {
        className: 'actions'
      },
        '-'
      )
    
    )
