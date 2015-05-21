# @cjsx React.DOM

# Imports
#
GlobalState     = require('global_state/state')
RoleMap         = require('utils/role_map')

RoleActions     = require('actions/roles')

RoleStore       = require('stores/role_store')
UserStore       = require('stores/user_store')

CancelButton    = require('components/form/buttons').CancelButton

# Main
#
Component = React.createClass

  propTypes:
    uuid: React.PropTypes.any.isRequired

  getRoleInput: ->
    @props.cursor.constants.get('invitable_roles').map (role) =>
      <label key="option-#{role}">
        <input 
          checked = {role is @state.role.value}
          type = "radio"
          name = "role-#{@props.uuid}"
          value = {role}
          onChange = {@onRoleChange}
        />
        <span>{RoleMap[role].name}</span>
      </label>

  onRevokeButtonClick: ->
    RoleActions.delete(@props.uuid)

  onRoleChange: (event) ->
    RoleActions.update(@props.uuid, { value: event.target.value })

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  getStateFromStores: (props) ->
    role = RoleStore.get(props.uuid)

    role: role
    user: if role then UserStore.get(role.user_id) else null
    sync: RoleStore.getSync(props.uuid)
  
  getInitialState: ->
    @getStateFromStores(@props)

  render: ->
    return null unless @state.role or @state.user

    <tr className="role">
      <td className='actions'>
        {
          if @state.role.value isnt 'owner'
            <CancelButton
              sync      = { @state.sync is "delete" }
              onClick   = { @onRevokeButtonClick } 
            />
        }
      </td>

      <td className="name">
        {@state.user.full_name}
        <span className="email">
          {@state.user.email}
        </span>
      </td>
      
      <td className="user-role">
        {
          if @state.role.value is "owner"
            RoleMap[@state.role.value].name
          else
            @getRoleInput().toArray()
        }
      </td>
    </tr>


# Exports
#
module.exports = Component
