# @cjsx React.DOM

# Imports
#
CompanyStore = require("stores/company")
RoleStore    = require("stores/role_store")
TokenStore   = require("stores/token_store")

TokenItem        = require("components/company/access_rights/token_item")
RoleItem         = require("components/company/access_rights/role_item")
InviteUserButton = require('components/company/buttons').InviteUserButton

# Main
#
Component = React.createClass

  refreshStateFromStores: ->
    @setState @getStateFromStores()

  getStateFromStores: ->
    company: CompanyStore.get(@props.uuid)
    roles:   RoleStore.all()
    tokens:  TokenStore.all()

  currentUsers: ->
    _.map @state.roles, (role) =>
      <RoleItem
        key             = role.uuid
        uuid            = role.uuid />
  
  currentTokens: ->
    _.map @state.tokens, (token) ->
      <TokenItem 
        key  = token.uuid
        uuid = token.uuid />

  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)

    RoleStore.on('change', @refreshStateFromStores)
    TokenStore.on('change', @refreshStateFromStores)
  
  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)

    RoleStore.off('change', @refreshStateFromStores)
    TokenStore.off('change', @refreshStateFromStores)

  propTypes:
    uuid:                    React.PropTypes.any.isRequired
    onInviteUserButtonClick: React.PropTypes.func

  getDefaultProps: ->
    onInviteUserButtonClick: -> 

  getInitialState: ->
    @getStateFromStores()
  
  render: ->
    if @state.company
      <div>
        <header>
          <strong>{@state.company.name}</strong> security settings
        </header>

        <InviteUserButton
          className = 'cc cc-wide'
          key       = 'invite-user-button'
          onClick   = @props.onInviteUserButtonClick />

        <table className='current-users-list'>
          <tbody>
            {
              [
                @currentUsers()
                @currentTokens()
              ]
            } 
          </tbody>
        </table>
      </div>

    else
      null


# Exports
#
module.exports = Component
