# @cjsx React.DOM

# Imports
#
RoleMap           = require('utils/role_map')

Buttons           = require('components/form/buttons') 
StandardButton    = Buttons.StandardButton
SyncButton        = Buttons.SyncButton

RoleStore         = require("stores/role_store.cursor")
UserStore         = require("stores/user_store.cursor")
PinboardStore     = require('stores/pinboard_store')


# Main
#
Component = React.createClass

  displayName: "RolesInviteForm"

  propTypes:
    ownerId:     React.PropTypes.string.isRequired
    ownerType:   React.PropTypes.string.isRequired
    onBackClick: React.PropTypes.func.isRequired
    roleValues:  React.PropTypes.array.isRequired

  getInitialState: ->
    isSyncing:   false
    attributes:  Immutable.Map()
    errors:      Immutable.Map()


  # Helpers
  #
  getRoleCopy: ->
    RoleMap[@props.ownerType]

  getPinboard: ->
    PinboardStore.cursor.items.get(@props.ownerId)


  # Handlers
  #
  handleInputChange: (name, event) ->
    @setState attributes: @state.attributes.set(name, event.target.value)


  # Renderers
  #
  renderRoleSelectors: ->
    @props.roleValues.map (roleValue) =>
      <label
        key       = { roleValue }
        className = "form-field-radio-2" >
        <input
          checked  =  { roleValue is @state.attributes.get('value') }
          name     =  "value"
          type     =  "radio"
          value    =  { roleValue }
          onChange =  { @handleInputChange.bind(@, 'value') } />
        <div className="title">
          { @getRoleCopy(roleValue).description }
          <div className="hint">
            { @getRoleCopy(roleValue).hint }
          </div>
        </div>
      </label>

  renderTwitterInput: ->
    <label className="cc-input-label">
      <input 
        className   = { if @state.errors.has('twitter') then 'cc-input error' else 'cc-input' }
        placeholder = '@twitter'
        onChange    = { @handleInputChange.bind(@, 'twitter') }
        value       = { @state.attributes.get('twitter', '') }  />
    </label>


  render: ->
    <section className="invite-form">
      <header>
        <StandardButton 
          className = "transparent"
          iconClass = "fa-angle-left"
          onClick   = { @props.onBackClick } />
        Share <strong>{ @getPinboard().get('title') }</strong> { @getRoleCopy(@state.attributes.get('value')).header }
      </header>

      <form onSubmit={ @onSubmit } >
        <fieldset className="roles">
          { @renderRoleSelectors() }
        </fieldset>

        <footer>
          { @renderTwitterInput() }

          <SyncButton 
            className = "cc cc-wide"
            text      = "Invite"
            sync      = { @isSyncing } />
        </footer>
      </form>
    </section>


# Exports
#
module.exports = Component
