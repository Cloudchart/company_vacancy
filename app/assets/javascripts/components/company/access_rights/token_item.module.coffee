# @cjsx React.DOM

# Imports
#
CompanyActions            = require('actions/company')
TokenStore                = require('stores/token_store')
Buttons                   = require('components/company/buttons')
ResendCompanyInviteButton = Buttons.ResendCompanyInviteButton
CancelCompanyInviteButton = Buttons.CancelCompanyInviteButton
RoleMap                   = require('utils/role_map')

# Main
#
Component = React.createClass

  refreshStateFromStores: ->
    @setState @getStateFromStores(@props)

  getStateFromStores: (props) ->
    token: TokenStore.get(props.uuid)
    sync:  TokenStore.getSync(@props.uuid)

  onCancelButtonClick: ->
    CompanyActions.cancelInvite(@props.uuid, 'delete')
  
  onResendButtonClick: ->
    CompanyActions.resendInvite(@props.uuid, 'update')

  componentDidMount: ->
    TokenStore.on('change', @refreshStateFromStores)

  componentWillUnmount: ->
    TokenStore.off('change', @refreshStateFromStores)

  propTypes:
    uuid: React.PropTypes.any.isRequired
  
  getInitialState: ->
    @getStateFromStores(@props)

  render: ->
    if @state.token
      <tr className="token">
        <td className="name">
          { @state.token.data.email }
        </td>
        
        <td className='user-role'>
          Invited as {RoleMap[@state.token.data.role].name}
        </td>
        
        <td className='actions'>
          { ResendCompanyInviteButton({className: 'cc-table'}, @state, @onResendButtonClick) }
          { CancelCompanyInviteButton({className: 'cc-table'}, @state, @onCancelButtonClick) }
        </td>
      </tr>

    else
      null


# Exports
#
module.exports = Component
