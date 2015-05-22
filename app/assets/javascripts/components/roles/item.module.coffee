# @cjsx React.DOM

# Imports
#
RoleMap         = require('utils/role_map')

RoleStore       = require('stores/role_store.cursor')

CancelButton    = require('components/form/buttons').CancelButton


# Main
#
Component = React.createClass

  propTypes:
    user:      React.PropTypes.any.isRequired
    role:      React.PropTypes.instanceOf(Immutable.Map)
    isOwner:   React.PropTypes.bool
    ownerType: React.PropTypes.string

  getDefaultProps: ->
    isOwner: false

  getInitialState: ->
    isSyncing: false


  # Helpers
  #
  getRoleCopy: (value) ->
    RoleMap[@props.ownerType][value]

  getRoleValue: (roleValue) ->
    if (pending_value = @props.role.get('pending_value')) then pending_value else @props.role.get('value')

    
  # Handlers
  #
  handleDeleteButtonClick: ->
    @setState isSyncing: true

    RoleStore.destroy(@props.role.get('uuid'))

  handleRoleChange: (event) ->
    RoleStore.update(@props.role.get('uuid'), { value: event.target.value })


  # Renderers
  #
  renderDeleteButton: ->
    return null if @props.isOwner

    <CancelButton
      sync      = { @state.isSyncing }
      onClick   = { @handleDeleteButtonClick } />

  renderRoleChooser: ->
    return @getRoleCopy('owner').name if @props.isOwner

    @props.roleValues.map (roleValue) =>
      <label key="option-#{roleValue}">
        <input 
          checked  = { roleValue is @getRoleValue() }
          type     = "radio"
          name     = "role-#{ @props.role.get('uuid') }"
          value    = { roleValue }
          onChange = { @handleRoleChange } />
        <span>{ @getRoleCopy(roleValue).name }</span>
      </label>


  render: ->
    <li className="role-item">
      { @renderDeleteButton() }

      <div className="name">
        { @props.user.get('full_name') }
        <span className="twitter">
          { @props.user.get('twitter') }
        </span>
      </div>
      
      <div className="role-chooser">
        { @renderRoleChooser() }
      </div>
    </li>


# Exports
#
module.exports = Component
