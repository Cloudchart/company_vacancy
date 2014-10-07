# Imports
#
tag = React.DOM


Actions     = require('actions/company')
TokenStore  = require('stores/token')
Buttons     = require('components/company/buttons')
roleMaps    = require('utils/role_maps')

syncIcon = ->
  (tag.i { className: 'fa fa-spinner fa-spin fa-fw' })

# Main
#
Component = React.createClass


  onCancelButtonClick: ->
    Actions.cancelInvite(@props.key, 'delete')
  
  
  onResendButtonClick: ->
    Actions.resendInvite(@props.key, 'update')
  
  
  componentWillReceiveProps: (nextProps) ->
    @setState(sync: nextProps.sync)
  
  
  getInitialState: ->
    sync: null


  render: ->
    (tag.tr {
      className: 'token'
    },
    
      (tag.td {
        className: 'name'
      },
        @props.email
      )
      
      
      (tag.td {
        className: 'user-role'
      },
        "Invited as #{roleMaps.RoleNameMap[@props.role]}"
      )
      
      
      (tag.td {
        className: 'actions'
      },
        
        Buttons.ResendCompanyInviteButton({className: 'cc-table'}, @state, @onResendButtonClick)
        Buttons.CancelCompanyInviteButton({className: 'cc-table'}, @state, @onCancelButtonClick)
      
      )
    
    )


# Exports
#
module.exports = Component
