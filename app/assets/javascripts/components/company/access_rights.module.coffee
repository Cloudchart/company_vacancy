# Imports
#
tag = React.DOM

CompanyStore              = require('stores/company_store')
UsersStore                = require('stores/users')
RolesStore                = require('stores/roles')
TokenStore                = require('stores/token_store')

Buttons           = require('components/company/buttons')
InviteUserForm    = require('components/company/invite_user_form')
CurrentUsersList  = require('components/company/current_users_list')


Modes           = ['view', 'edit']


#
#
tokenFilter = (key, record) ->
  record.get('owner_id') == key and record.get('owner_type') == 'Company' and record.get('name') == 'invite'


# Get State From Stores
#
getStateFromStores = (key) ->
  tokens        = TokenStore.filter(tokenFilter.bind(null, key))
  roles         = RolesStore.filter (item) -> item.owner_id == key and item.owner_type == 'Company'
  user_ids      = _.pluck roles, 'user_id'
  users         = UsersStore.filter (item) -> _.contains user_ids, item.uuid
  
  company:        CompanyStore.get(key)
  users:          users
  roles:          roles
  tokens:         if tokens then tokens.toJS() else {}


# Main
#
Component = React.createClass

  
  hasNewToken: ->
    @state.newTokenKey and TokenStore.has(@state.newTokenKey)


  refreshStateFromStores: ->
    @setState getStateFromStores(@props.key)
    @setState({ mode: 'view' }) unless @hasNewToken()


  onInviteUserButtonClick: (event) ->
    @setState({ newTokenKey: TokenStore.create() }) unless @hasNewToken()
    @setState({ mode: 'edit' })
  
  
  onCurrentUsersButtonClick: (event) ->
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
    mode: Modes[0]
  
  
  getInitialState: ->
    state = getStateFromStores(@props.key)
    state.roles           = @props.roles
    state.mode            = @props.mode
    state


  render: ->
    (tag.div {
      className: 'access-rights'
    },
    
      
      switch @state.mode
        
        when 'view'
          [
            # Invite User Button
            #
            (Buttons.InviteUserButton {
              key:      'invite-user-button'
              onClick:  @onInviteUserButtonClick
            })
            
            (tag.hr { key: 'hr' })
            
            # Current Users List
            #
            (CurrentUsersList {
              key:      'current-users-list'
              company:  @state.company
              tokens:   @state.tokens
              users:    @state.users
              roles:    @state.roles
            })
          ]
        
        
        when 'edit'
          [
            # Current Users Button
            #
            (Buttons.CurrentUsersButton {
              key:      'current-users-button'
              onClick:  @onCurrentUsersButtonClick
            })
            
            (tag.hr { key: 'hr' })

            # Invite User Form
            #
            (InviteUserForm {
              key:      @state.newTokenKey
              company:  @state.company
              roles:    @props.roles
              token:    TokenStore.get(@state.newTokenKey)
              errors:   TokenStore.getErrors(@state.newTokenKey)
            })
          ]

    )


# Exports
#
module.exports = Component
