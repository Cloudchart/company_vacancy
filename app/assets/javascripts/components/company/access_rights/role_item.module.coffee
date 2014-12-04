# @cjsx React.DOM

# Imports
#
SyncButton      = require('components/company/buttons').SyncButton
RoleActions     = require('actions/roles')
RoleStore       = require('stores/role_store')
UserStore       = require('stores/user_store')
RoleMap         = require('utils/role_map')
TempKVStore     = require('utils/temp_kv_store')

# Main
#
Component = React.createClass

  refreshStateFromStores: ->
    @setState @getStateFromStores(@props)

  getStateFromStores: (props) ->
    role = RoleStore.get(props.uuid)

    role: role
    user: if role then UserStore.get(role.user_id) else null
    sync: RoleStore.getSync(@props.uuid)
    invitableRoles: TempKVStore.get("invitable_roles") || []

  getOptions: ->
    _.map(@state.invitableRoles, (role) =>
      <option value={role} key="option-#{role}">{RoleMap[role].name}</option>
    )

  onRevokeButtonClick: ->
    RoleActions.delete(@props.key)

  onSelectRoleChange: (e) ->
    RoleActions.update(@props.key, { value: e.target.value })

  componentDidMount: ->
    RoleStore.on("change", @refreshStateFromStores)
    UserStore.on("change", @refreshStateFromStores)
    TempKVStore.on("invitable_roles_changed", @refreshStateFromStores)

  componentWillUnmount: ->
    RoleStore.off("change", @refreshStateFromStores)
    UserStore.off("change", @refreshStateFromStores)
    TempKVStore.off("invitable_roles_changed", @refreshStateFromStores)

  propTypes:
    uuid: React.PropTypes.any.isRequired
  
  getInitialState: ->
    @getStateFromStores(@props)

  render: ->
    if @state.role && @state.user
      role = @state.role.value

      <tr className="role">
        <td className="name">
          {@state.user.full_name}
          <span className="email">
            {@state.user.email}
          </span>
        </td>
        
        <td className="user-role">
          {
            if @state.role.value == "owner"
              RoleMap[role].name
            else
              [
                <select
                  key       = "select"
                  value     = role
                  onChange  = @onSelectRoleChange>
                  { @getOptions() }
                </select>
                <i key="icon" className="fa fa-chevron-down"></i>
              ]
          }
        </td>
        
        <td className='actions'>
          {
            if role != 'owner'
              SyncButton
                className : 'cc-table revoke'
                title     : 'Revoke'
                sync      : @state.sync == 'revoke'
                disabled  : @state.sync
                onClick   : @onRevokeButtonClick
          }
        </td>
      </tr>


# Exports
#
module.exports = Component
