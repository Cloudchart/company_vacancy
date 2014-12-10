# @cjsx React.DOM

# Imports
#
CompanyStore = require("stores/company")
RoleStore    = require("stores/role_store")
TokenStore   = require("stores/token_store")

TokenItem        = require("components/company/access_rights/token_item")
RoleItem         = require("components/company/access_rights/role_item")
StandardButton   = require('components/form/buttons').StandardButton

# Main
#
Component = React.createClass

  refreshStateFromStores: ->
    @setState @getStateFromStores()

  getStateFromStores: ->
    company: CompanyStore.get(@props.uuid)
    roles:   RoleStore.filter (role) => role.owner_id == @props.uuid && role.owner_type == "Company"
    tokens:  TokenStore.filter (token) => token.owner_id == @props.uuid && token.owner_type == "Company"

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
            onClick   = @props.onInviteUserButtonClick />
        </section>
      </div>

    else
      null


# Exports
#
module.exports = Component
