# @cjsx React.DOM

# Imports
#
CompanyStore     = require("stores/company")
RoleStore        = require("stores/role_store")
TokenStore       = require("stores/token_store")

TokenItem        = require("components/company/access_rights/token_item")
RoleItem         = require("components/company/access_rights/role_item")
StandardButton   = require('components/form/buttons').StandardButton

# Main
#
Component = React.createClass

  propTypes:
    uuid:                    React.PropTypes.any.isRequired
    onInviteUserButtonClick: React.PropTypes.func

  currentUsers: ->
    _.map @state.roles, (role, index) =>
      <RoleItem
        key = {index}
        uuid = {role.uuid}
        cursor = {@props.cursor}
      />
  
  currentTokens: ->
    _.map @state.tokens, (token, index) ->
      <TokenItem 
        key  = {index}
        uuid = {token.uuid}
      />

  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)

    RoleStore.on('change', @refreshStateFromStores)
    TokenStore.on('change', @refreshStateFromStores)
  
  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)

    RoleStore.off('change', @refreshStateFromStores)
    TokenStore.off('change', @refreshStateFromStores)

  refreshStateFromStores: ->
    @setState @getStateFromStores()

  getStateFromStores: ->
    company: CompanyStore.get(@props.uuid)
    roles:   RoleStore.filter (role) => role.owner_id is @props.uuid and role.owner_type is "Company"
    tokens:  TokenStore.filter (token) => token.owner_id is @props.uuid and token.owner_type is "Company"

  getDefaultProps: ->
    onInviteUserButtonClick: -> 

  getInitialState: ->
    @getStateFromStores()
  
  render: ->
    return null unless @state.company

    <div>
      <header>
        <strong>{@state.company.name}</strong> security settings
      </header>

      <section className="users-list content">
        <table>
          <tbody>
            {
              [
                @currentUsers()
                @currentTokens()
              ]
            } 
          </tbody>
        </table>

        <StandardButton
          className = "cc cc-wide"
          text      = "Invite"
          onClick   = {@props.onInviteUserButtonClick}
        />
      </section>
    </div>


# Exports
#
module.exports = Component
