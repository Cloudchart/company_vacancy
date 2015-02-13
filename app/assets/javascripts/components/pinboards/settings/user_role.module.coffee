# @cjsx React.DOM


#Stores
#
RoleStore = require('stores/role_store.cursor')


# Roles
#
Roles = Immutable.Seq
  editor:     'Editor'
  reader:     'Reader'
  follower:   'Nobody'


# Exports
#
module.exports = React.createClass

  displayName: 'PinboardSettingsUserRole'


  handleChange: (event) ->
    RoleStore.update(@props.role.get('uuid'), { value: event.target.value })


  renderRoleInput: (title, key) ->
    <td key={ key }>
      <label>
        <input
          name      = "#{@props.user.get('uuid')}-role"
          type      = "radio"
          value     = { key }
          checked   = { key == @props.role.get('value') }
          onChange  = { @handleChange }
        />
        { title }
      </label>
    </td>


  renderRolesInputs: ->
    Roles.map(@renderRoleInput)


  render: ->
    <tr>
      <td>
        { @props.user.get('full_name') }
      </td>
      { @renderRolesInputs().toArray() }
    </tr>
