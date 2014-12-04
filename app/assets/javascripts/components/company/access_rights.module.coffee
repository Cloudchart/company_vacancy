# @cjsx React.DOM

# Imports
#
CompanyInviteUserForm   = require("components/company/access_rights/invite_user_form")
CompanyUsersList        = require("components/company/access_rights/users_list")

TokenStore              = require("stores/token_store")

Modes = 
  VIEW:   "view"
  INVITE: "invite"

# Main
#
Component = React.createClass

  refreshStateFromStores: ->
    @setState @getStateFromStores()

  getStateFromStores: ->
    mode: if @hasNewToken() then Modes.INVITE else Modes.VIEW

  hasNewToken: ->
    @state.newTokenKey and TokenStore.has(@state.newTokenKey)

  createNewToken: ->
    TokenStore.create({ owner_id: @props.uuid, owner_type: 'Company' })

  onInviteUserButtonClick: (event) ->
    @setState
      mode: Modes.INVITE
      newTokenKey: @createNewToken()
  
  onCurrentUsersButtonClick: (event) ->
    TokenStore.remove(@state.newTokenKey) if @hasNewToken()

    @setState({ mode: Modes.VIEW })

  componentDidMount: ->
    TokenStore.on("change", @refreshStateFromStores)
  
  componentWillUnmount: ->
    TokenStore.off("change", @refreshStateFromStores)

  propTypes:
    uuid: React.PropTypes.any.isRequired
  
  getInitialState: ->
    mode: Modes.VIEW

  render: ->
    <div className="access-rights">
      {
        switch @state.mode
        
          when Modes.VIEW
            <CompanyUsersList
              uuid                    = @props.uuid
              onInviteUserButtonClick = @onInviteUserButtonClick />

          when Modes.INVITE
            <CompanyInviteUserForm
              uuid                      = @props.uuid
              tokenKey                  = @state.newTokenKey
              onCurrentUsersButtonClick = @onCurrentUsersButtonClick
            />
      }
    </div>

# Exports
#
module.exports = Component
