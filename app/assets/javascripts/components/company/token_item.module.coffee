# Imports
#
tag = React.DOM


Actions     = require('actions/company')
TokenStore  = require('stores/token')
Buttons     = require('components/company/buttons')


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
        className: 'email'
      },
        @props.email
      )
      
      
      (tag.td {
        className: 'role'
      },
        @props.role
      )
      
      
      (tag.td {
        className: 'actions'
      },
        
        Buttons.ResendCompanyInviteButton(@props, @state, @onResendButtonClick)
        Buttons.CancelCompanyInviteButton(@props, @state, @onCancelButtonClick)
      
      )
    
    )


# Exports
#
module.exports = Component
