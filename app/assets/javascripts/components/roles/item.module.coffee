# @cjsx React.DOM

# Imports
#
RoleMap       = require('utils/role_map')

RoleStore     = require('stores/role_store.cursor')
PinboardStore = require('stores/pinboard_store')

CancelButton  = require('components/form/buttons').CancelButton

Tooltip       = require('components/shared/tooltip')


# Main
#
Component = React.createClass

  propTypes:
    user:        React.PropTypes.any
    role:        React.PropTypes.instanceOf(Immutable.Map)
    token:       React.PropTypes.instanceOf(Immutable.Map)
    owner:       React.PropTypes.instanceOf(Immutable.Map).isRequired
    ownerType:   React.PropTypes.string.isRequired

  getInitialState: ->
    isSyncing: false


  # Helpers
  #
  getRoleCopy: (value) ->
    RoleMap[@props.ownerType][value]

  isPending: ->
    @props.role && @props.role.get('pending_value')

  hasRequestedAccess: ->
    @props.token

  getRoleValue: (roleValue) ->
    return null if @hasRequestedAccess()

    if @isPending() then @props.role.get('pending_value') else @props.role.get('value')

  isUserOwner: ->
    return false unless @props.user

    @props.owner.get('user_id') == @props.user.get('uuid')

    
  # Handlers
  #
  handleDeleteButtonClick: ->
    @setState isSyncing: true

    if @props.role
      RoleStore.destroy(@props.role.get('uuid'))
    else if @props.token
      PinboardStore.denyAccess(@props.owner, @props.token)

  handleRoleChange: (event) ->
    if @props.role
      RoleStore.update(@props.role.get('uuid'), { value: event.target.value })
    else if @props.token
      PinboardStore.grantAccess(@props.owner, @props.token, event.target.value)


  # Renderers
  #
  renderInviteMessage: ->
    return null unless @hasRequestedAccess()

    <article className="message">
      <p>
        { @props.token.get('data').get('message') }
      </p>
    </article>

  renderDeleteButton: ->
    return null if @isUserOwner()

    <CancelButton
      sync      = { @state.isSyncing }
      onClick   = { @handleDeleteButtonClick } />

  renderStatus: ->
    return null if @isUserOwner() || !@isPending()

    <span className="status">
      Pending invite, can only view board.
    </span>

  renderRoleChooser: ->
    return @getRoleCopy('owner').name if @isUserOwner()

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
      { @renderInviteMessage() }
      { @renderDeleteButton() }
      { @renderUser() }
      
      <div className="role-chooser">
        { @renderRoleChooser() }
      </div>
    </li>


# Exports
#
module.exports = Component
