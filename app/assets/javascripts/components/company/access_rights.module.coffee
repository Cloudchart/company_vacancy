# @cjsx React.DOM

# Imports
#
GlobalState = require('global_state/state')

CompanyStore = require("stores/company")
RoleStore  = require("stores/role_store")
UserStore = require("stores/user_store")
TokenStore = require("stores/token_store")

CompanyInviteUserForm = require("components/company/access_rights/invite_user_form")
CompanyUsersList = require("components/company/access_rights/users_list")

Modes = 
  VIEW:   "view"
  INVITE: "invite"

# Main
#
Component = React.createClass

  mixins: [GlobalState.mixin]

  propTypes:
    uuid: React.PropTypes.any.isRequired

  # Helpers
  # 
  hasNewToken: ->
    @state.newTokenKey and TokenStore.has(@state.newTokenKey)

  createNewToken: ->
    TokenStore.create({ owner_id: @props.uuid, owner_type: 'Company' })

  # Handlers
  # 
  onInviteUserButtonClick: (event) ->
    @setState
      mode: Modes.INVITE
      newTokenKey: @createNewToken()
  
  onCurrentUsersButtonClick: (event) ->
    TokenStore.remove(@state.newTokenKey) if @hasNewToken()

    @setState({ mode: Modes.VIEW })

  # Lifecylce Methods
  # 
  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)
    RoleStore.on('change', @refreshStateFromStores)
    UserStore.on('change', @refreshStateFromStores)
    TokenStore.on("change", @refreshStateFromStores)
  
  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)
    RoleStore.off('change', @refreshStateFromStores)
    UserStore.off('change', @refreshStateFromStores)
    TokenStore.off("change", @refreshStateFromStores)

  onGlobalStateChange: ->
    @setState({ refreshed_at: Date.now() })

  # Component Specifications
  # 
  refreshStateFromStores: ->
    @setState @getStateFromStores()

  getStateFromStores: ->
    mode: if @hasNewToken() then Modes.INVITE else Modes.VIEW

  getDefaultProps: ->
    cursor:
      constants: GlobalState.cursor(['constants', 'companies'])
  
  getInitialState: ->
    mode: Modes.VIEW
    refreshed_at: null

  render: ->
    return null unless @state.refreshed_at

    <div className="access-rights">
      {
        switch @state.mode
        
          when Modes.VIEW
            <CompanyUsersList
              uuid                    = {@props.uuid}
              cursor                  = {@props.cursor}
              onInviteUserButtonClick = {@onInviteUserButtonClick}
            />

          when Modes.INVITE
            <CompanyInviteUserForm
              uuid                      = {@props.uuid}
              cursor                    = {@props.cursor}
              tokenKey                  = {@state.newTokenKey}
              onCurrentUsersButtonClick = {@onCurrentUsersButtonClick}
            />
      }
    </div>

# Exports
#
module.exports = Component
