# Imports
#
tag = React.DOM

CloudFlux = require('cloud_flux')

CompanyStore  = require('stores/company')
UserStore = require('stores/user_store')
RoleStore = require('stores/role_store')
TokenStore = require('stores/token_store')

Buttons = require('components/company/buttons')
InviteUserForm = require('components/company/invite_user_form')
CurrentUsersList = require('components/company/current_users_list')

Modes = ['view', 'edit']

# Main
#
Component = React.createClass

  hasNewToken: ->
    @state.newTokenKey and TokenStore.has(@state.newTokenKey)
  
  
  onInviteUserButtonClick: (event) ->
    @setState({ newTokenKey: TokenStore.create({ owner_id: @props.key, owner_type: 'Company' }) }) unless @hasNewToken()
    @setState({ mode: 'edit' })
  
  
  onCurrentUsersButtonClick: (event) ->
    event.preventDefault()

    TokenStore.remove(@state.newTokenKey) if @hasNewToken()
    @setState({ mode: 'view' })
  
  
  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)
    # UserStore.on('change', @refreshStateFromStores)
    RoleStore.on('change', @refreshStateFromStores)
    TokenStore.on('change', @refreshStateFromStores)
  
  
  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)
    # UserStore.off('change', @refreshStateFromStores)
    RoleStore.off('change', @refreshStateFromStores)
    TokenStore.off('change', @refreshStateFromStores)


  refreshStateFromStores: ->
    @setState @getStateFromStores(@props)
    @setState({ mode: 'view' }) unless @hasNewToken()


  getStateFromStores: (props) ->
    company: CompanyStore.get(props.uuid)
    roles: RoleStore.all()
    tokens: TokenStore.all()
  
  
  getDefaultProps: ->
    mode: 'view'
    # invitable_roles: []
    # emails: []
  
  getInitialState: ->
    state = @getStateFromStores(@props)
    state.mode = @props.mode
    state.newTokenKey = TokenStore.create({ owner_id: @props.uuid, owner_type: 'Company' })
    state


  render: ->
    if @state.company
      (tag.div {
        className: 'access-rights'
      },
      
        
        switch @state.mode
          
          when 'view'
            [
              (tag.header { key: "access-right-header" },
                (tag.strong {}, @state.company.name)
                " security settings"
              )

              # Invite User Button
              #
              (Buttons.InviteUserButton {
                className: 'cc cc-wide'
                key:       'invite-user-button'
                onClick:   @onInviteUserButtonClick
              })
              
              # Current Users List
              #
              (CurrentUsersList {
                key:             'current-users-list'
                company:         @state.company
                tokens:          @state.tokens
                roles:           @state.roles
                invitable_roles: @props.invitable_roles
              })
            ]
          
          
          when 'edit'
            [
              # Invite User Form
              #
              (InviteUserForm {
                onCurrentUsersButtonClick: @onCurrentUsersButtonClick
                key:                       @state.newTokenKey
                company:                   @state.company
                # emails:                    @props.emails
                invitable_roles:           @props.invitable_roles
                token:                     TokenStore.get(@state.newTokenKey)
                errors:                    TokenStore.errorsFor(@state.newTokenKey)
                sync:                      TokenStore.getSync(@state.newTokenKey)
              })
            ]

      )
    else
      null


# Exports
#
module.exports = Component
