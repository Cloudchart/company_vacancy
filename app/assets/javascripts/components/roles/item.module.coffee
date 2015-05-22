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

  isPending: ->
    @props.role.get('pending_value')

  getRoleValue: (roleValue) ->
    if @isPending() then @props.role.get('pending_value') else @props.role.get('value')

    
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

  renderStatus: ->
    return null if @props.isOwner || !@isPending()

    <span className="status">
      Pending invite, can only view board.
    </span>

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
          @{ @props.user.get('twitter') }
        </span>
        { @renderStatus() }
      </div>
      
      <div className="role-chooser">
        { @renderRoleChooser() }
      </div>
    </li>


# Exports
#
module.exports = Component
