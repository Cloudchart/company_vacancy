# Imports
#
tag = React.DOM

CompanyStore              = require('stores/company')
UsersStore                = require('stores/users')
RolesStore                = require('stores/roles')
TokenStore                = require('stores/token')

CloudFlux                 = require('cloud_flux')

Buttons           = require('components/company/buttons')
InviteUserForm    = require('components/company/invite_user_form')
CurrentUsersList  = require('components/company/current_users_list')


Modes             = ['view', 'edit']


#
#
tokenFilter = (key, record) ->
  record.owner_id == key and record.owner_type == 'Company' and record.name == 'invite'


roleFilter = (key, record) ->
  record.owner_id == key and record.owner_type == 'Company'


# Get State From Stores
#
getStateFromStores = (key) ->
  tokens        = TokenStore.filter(tokenFilter.bind(null, key))
  roles         = RolesStore.filter(roleFilter.bind(null, key))
  
  company:  CompanyStore.get(key)
  roles:    roles
  tokens:   tokens


# Main
#
Component = React.createClass

  hasNewToken: ->
    @state.newTokenKey and TokenStore.has(@state.newTokenKey)

  refreshStateFromStores: ->
    @setState getStateFromStores(@props.key)
    @setState({ mode: 'view' }) unless @hasNewToken()
  
  
  onInviteUserButtonClick: (event) ->
    @setState({ newTokenKey: TokenStore.create({ owner_id: @props.key, owner_type: 'Company' }) }) unless @hasNewToken()
    @setState({ mode: 'edit' })
  
  
  onCurrentUsersButtonClick: (event) ->
    event.preventDefault()

    TokenStore.remove(@state.newTokenKey) if @hasNewToken()
    @setState({ mode: 'view' })
  
  
  componentDidMount: ->
    TokenStore.on('change', @refreshStateFromStores)
    UsersStore.on('change', @refreshStateFromStores)
    RolesStore.on('change', @refreshStateFromStores)
  
  
  componentWillUnmount: ->
    TokenStore.off('change', @refreshStateFromStores)
    UsersStore.off('change', @refreshStateFromStores)
    RolesStore.off('change', @refreshStateFromStores)
  
  
  getDefaultProps: ->
    invitable_roles: []
    mode: 'edit'
    emails: []
  
  getInitialState: ->
    state = getStateFromStores(@props.key)
    state.mode = @props.mode
    state.newTokenKey = TokenStore.create({ owner_id: @props.key, owner_type: 'Company' })
    state


  render: ->
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
              emails:                    @props.emails
              invitable_roles:           @props.invitable_roles
              token:                     TokenStore.get(@state.newTokenKey)
              errors:                    TokenStore.errorsFor(@state.newTokenKey)
              sync:                      TokenStore.getSync(@state.newTokenKey)
            })
          ]

    )


# Exports
#
module.exports = Component
