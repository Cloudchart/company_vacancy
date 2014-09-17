# Imports
#
tag = React.DOM

TokenActions = require('actions/token_actions')


# Main
#
Component = React.createClass


  nameCell: (record, key) ->
    (tag.td {
      className: 'name'
    },
      record.data.email
    )
  
  
  roleCell: (record, key) ->
    (tag.td {
      className: 'role'
    },
      record.data.role.toUpperCase()
    )
  
  
  actionsCell: (record, key) ->
    (tag.td {
      className: 'actions'
    },
      (tag.button {
        onClick:  @onCancelButtonClick.bind(@, key)
      },
        'Cancel'
        (tag.i { className: 'fa fa-times' })
      )

      (tag.button {
        onClick:  @onResendButtonClick.bind(@, key)
      },
        'Resend'
        (tag.i { className: 'fa fa-send-o' })
      )
    )


  currentUsers: ->
    _.map @props.tokens, (record, key) =>
      (tag.tr {
        key: key
      },
      
        @nameCell(record, key)

        @roleCell(record, key)
        
        @actionsCell(record, key)

      )
  
  
  onCancelButtonClick: (key, event) ->
    TokenActions.deleteCompanyInvite(key, @props.company.uuid)


  onResendButtonClick: (key, event) ->


  render: ->
    (tag.table {
      className: 'current-users-list'
    },
      @currentUsers()
    )


# Exports
#
module.exports = Component
