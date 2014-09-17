# Imports
#
tag = React.DOM


Actions     = require('actions/token_actions')
TokenStore  = require('stores/token_store')
Buttons     = require('components/company/buttons')


syncIcon = ->
  (tag.i { className: 'fa fa-spinner fa-spin fa-fw' })


# Main
#
Component = React.createClass


  onCancelButtonClick: ->
    Actions.deleteCompanyInvite(@props.key, @props.company.key)
  
  
  onResendButtonClick: ->
    Actions.resendCompanyInvite(@props.key, @props.company.key)
  
  
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
