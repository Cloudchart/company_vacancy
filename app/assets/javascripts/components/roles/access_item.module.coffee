# @cjsx React.DOM

# Imports
#
GlobalState = require('global_state/state')

RoleStore = require('stores/role_store.cursor')

CancelButton = require('components/form/buttons').CancelButton
Tooltip = require('components/shared/tooltip')

RoleMap = require('utils/role_map')
getOwnerName = require('utils/owners').getName
getOwnerStore = require('utils/owners').getStore


# Main
#
Component = React.createClass

  propTypes:
    user:        React.PropTypes.any
    role:        React.PropTypes.instanceOf(Immutable.Map)
    owner:       React.PropTypes.instanceOf(Immutable.Map).isRequired
    ownerType:   React.PropTypes.string.isRequired
    isUserOwner: React.PropTypes.bool

  getInitialState: ->
    isSyncing:   false
    isUserOwner: false


  # Helpers
  #
  getRoleCopy: (value) ->
    RoleMap[@props.ownerType][value]

  isPending: ->
    @props.role && @props.role.get('pending_value')

  getRoleValue: (roleValue) ->
    if @isPending() then @props.role.get('pending_value') else @props.role.get('value')

    
  # Handlers
  #
  handleDeleteButtonClick: ->
    @setState isSyncing: true
    RoleStore.destroy(@props.role.get('uuid'))
    GlobalState.fetchEdges('Pinboard', @props.owner.get('uuid'), 'role_ids')

  handleRoleChange: (event) ->
    RoleStore.update(@props.role.get('uuid'), { value: event.target.value })


  # Renderers
  #
  renderDeleteButton: ->
    return null if @props.isUserOwner

    <CancelButton
      sync      = { @state.isSyncing }
      onClick   = { @handleDeleteButtonClick } />

  renderStatus: ->
    return null if @props.isUserOwner || !@isPending()

    <span className="status">
      Pending invite, can only view { getOwnerName(@props.ownerType) }.
    </span>

  renderRoleChooser: ->
    return @getRoleCopy('owner').name if @props.isUserOwner

    @props.roleValues.map (roleValue) =>
      <label key="option-#{roleValue}">
        <input 
          checked  = { roleValue is @getRoleValue() }
          type     = "radio"
          value    = { roleValue }
          onChange = { @handleRoleChange } />
        <span>{ @getRoleCopy(roleValue).name }</span>
      </label>

  renderUser: ->
    return null unless @props.user

    <div className="name">
      { @props.user.get('full_name') }
      <span className="twitter">
        @{ @props.user.get('twitter') }
      </span>
      { @renderStatus() }
    </div>


  render: ->
    <li className="role-item">
      { @renderDeleteButton() }
      { @renderUser() }
      
      <div className="role-chooser">
        { @renderRoleChooser() }
      </div>
    </li>


# Exports
#
module.exports = Component
