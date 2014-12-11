# @cjsx React.DOM

# Imports
#
CompanyActions            = require('actions/company')
TokenStore                = require('stores/token_store')
Buttons                   = require('components/form/buttons')
SyncButton                = Buttons.SyncButton
CancelButton              = Buttons.CancelButton
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
        <td className="actions">
          <CancelButton
            sync      = {@state.sync == "delete"}
            onClick   = @onCancelButtonClick />
        </td>

        <td className="name">
          { @state.token.data.get('email') }
        </td>
        
        <td className='user-role'>
          Invited as {RoleMap[@state.token.data.get('role')].name}
          <SyncButton
            className    = "transparent"
            sync         = {@state.sync == "update"}
            iconClass    = "fa-send-o"
            onClick      = @onResendButtonClick />
        </td>
      </tr>

    else
      null


# Exports
#
module.exports = Component
