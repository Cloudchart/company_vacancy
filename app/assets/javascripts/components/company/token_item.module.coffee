# Imports
#
tag = React.DOM


Actions     = require('actions/company')
TokenStore  = require('stores/token_store')
Buttons     = require('components/company/buttons')
RoleMap     = require('utils/role_map')

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
    if @props.role # temp fix

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
          "Invited as #{RoleMap[@props.role].name}"
        )
        
        
        (tag.td {
          className: 'actions'
        },
          
          Buttons.ResendCompanyInviteButton({className: 'cc-table'}, @state, @onResendButtonClick)
          Buttons.CancelCompanyInviteButton({className: 'cc-table'}, @state, @onCancelButtonClick)
        
        )
      
      )
    else
      null


# Exports
#
module.exports = Component
