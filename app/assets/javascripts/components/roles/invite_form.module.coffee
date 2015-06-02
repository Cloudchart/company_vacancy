# @cjsx React.DOM

# Imports
#
RoleMap           = require('utils/role_map')

Buttons           = require('components/form/buttons') 
StandardButton    = Buttons.StandardButton
SyncButton        = Buttons.SyncButton

Checkbox          = require('components/form/checkbox')

RoleStore         = require("stores/role_store.cursor")
UserStore         = require("stores/user_store.cursor")

OwnerStores =
  'Company':     require('stores/company_store.cursor')
  'Pinboard':    require('stores/pinboard_store')


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
    attributes:  @getDefaultAttributes()
    errors:      Immutable.Map()
    showEmail:   false


  # Helpers
  #
  getRoleCopy: (value) ->
    RoleMap[@props.ownerType][value]

  getOwnerStore: ->
    OwnerStores[@props.ownerType]

  getOwner: ->
    @getOwnerStore().cursor.items.get(@props.ownerId)

  getOwnerName: ->
    switch @props.ownerType
      when 'Pinboard'
        @getOwner().get('title')
      when 'Company'
        @getOwner().get('name')


  getDefaultAttributes: ->
    Immutable.Map(
      value:      @props.roleValues[0]
      owner_id:   @props.ownerId
      owner_type: @props.ownerType
    )


  # Handlers
  #
  handleInputChange: (name, event) ->
    @setState attributes: @state.attributes.set(name, event.target.value)

  handleSubmit: (event) ->
    event.preventDefault()

    @setState isSyncing: true

    RoleStore.create(@state.attributes.toJSON()).then @handleSubmitDone, @handleSubmitFail

  handleSubmitDone: ->
    @setState
      attributes:  @getDefaultAttributes()
      errors:      Immutable.Map()
      isSyncing:   false

    @props.onBackClick()

  handleSubmitFail: (reason) ->
    @setState
      errors:    Immutable.Map(reason.responseJSON.errors)
      isSyncing: false

  handleEmailVisibilityChange: (value) ->
    @setState
      showEmail:  value
      attributes: @state.attributes.delete('email')


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

  renderEmailInput: ->
    return null unless @state.showEmail

    <label className="cc-input-label">
      <input 
        className   = { if @state.errors.has('email') then 'cc-input error' else 'cc-input' }
        placeholder = 'Email'
        onChange    = { @handleInputChange.bind(@, 'email') }
        value       = { @state.attributes.get('email', '') }  />
    </label>

  renderEmailCheckbox: ->
    <Checkbox
      checked   = { @state.showEmail }
      onChange  = { @handleEmailVisibilityChange } >
      Notify by email
    </Checkbox>


  render: ->
    <section className="invite-form">
      <header>
        <StandardButton 
          className = "transparent"
          iconClass = "fa-angle-left"
          onClick   = { @props.onBackClick } />
        Share <strong>{ @getOwnerName() }</strong> { @getRoleCopy(@state.attributes.get('value')).header }
      </header>

      <form onSubmit={ @handleSubmit } >
        <fieldset className="roles">
          { @renderRoleSelectors() }
        </fieldset>

        <footer>
          { @renderTwitterInput() }
          { @renderEmailInput() }
          { @renderEmailCheckbox() }

          <SyncButton 
            className = "cc"
            text      = "Invite"
            sync      = { @state.isSyncing } />
        </footer>
      </form>
    </section>


# Exports
#
module.exports = Component
