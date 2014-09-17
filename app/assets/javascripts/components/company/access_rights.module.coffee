# Imports
#
tag = React.DOM

TokenStore      = require('stores/token_store')

Buttons         = require('components/company/buttons')
InviteUserForm  = require('components/company/invite_user_form')


# Main
#
Component = React.createClass


  onInviteUserButtonClick: (event) ->
    @setState({ new_invite_key: 'abc' })
  
  
  onCurrentUsersButtonClick: (event) ->
    @setState({ new_invite_key: null })
  
  
  getInitialState: ->
    new_invite_key: null


  render: ->
    (tag.div {
      className: 'access-rights'
    },
    
      if @state.new_invite_key

        [
          # Current Users Button
          #
          (Buttons.CurrentUsersButton {
            key:      'current-users-button'
            onClick:  @onCurrentUsersButtonClick
          })
        
        
          # Invite User Form
          #
          (InviteUserForm {
            key:          @state.new_invite_key
            company_key:  @props.key
            data:         {}
          })
        ]

      else

        # Invite User Button
        #
        (Buttons.InviteUserButton {
          onClick: @onInviteUserButtonClick
        }) unless @state.new_invite_key
        
        # Current Users List
        #
      

    )


# Exports
#
module.exports = Component
