# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinboardStore = require('stores/pinboard_store')
UserStore     = require('stores/user_store.cursor')
RoleStore     = require('stores/role_store.cursor')


# Components
#
ModalStack = require('components/modal_stack')
InviteForm = require('components/pinboards/invite_form')
# Security = require('')


# Fields
#
Fields = Immutable.Seq(['title', 'description', 'access_rights'])


# Access rights
#
AccessRights = Immutable.Seq
  public:     'Open to everyone'
  protected:  'Invite-only group'
  private:    'Private group'


# Exports
#
module.exports = React.createClass

  displayName: 'PinboardSettings'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:

    queries:
      pinboard: ->
        """
          Pinboard {
            user,
            writers,
            readers,
            followers,
            roles
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.uuid }).then =>
      @setState @getStateFromStores()


  save: ->
    return unless Fields.some (name) =>
      @state.attributes.get(name) isnt @cursor.pinboard.get(name)

    PinboardStore.update(@props.uuid, @state.attributes.toJS())


  handleSubmit: (event) ->
    event.preventDefault()
    @save()


  handleChange: (name, event) ->
    @setState
      attributes: @state.attributes.set(name, event.target.value)


  handleAccessRightsChange: (event) ->
    @setState
      attributes: @state.attributes.set('access_rights', event.target.value)

    clearTimeout @__accessRightsSaveTimeout
    @__accessRightsSaveTimeout = setTimeout @save, 250


  handleBlur: (event) ->
    @save()


  handleKeyDown: (event) ->
    return unless event.key == 'Enter'
    event.target.blur()


  handleinviteClick: (event) ->
    # TODO: get invitable roles and contacts from server
    ModalStack.show <InviteForm pinboard={@cursor.pinboard} />


  getAttributesFromCursor: ->
    Fields

      .reduce (memo, name) =>
        memo.set(name, @cursor.pinboard.get(name)) if @cursor
        memo
      , Immutable.Map().asMutable()

      .asImmutable()



  componentWillMount: ->
    @cursor =
      pinboard: PinboardStore.cursor.items.cursor(@props.uuid)

    @fetch()


  onGlobalStateChange: ->
    @setState @getStateFromStores()


  getStateFromStores: ->
    attributes:   @getAttributesFromCursor()
    editors:      PinboardStore.editorsFor(@props.uuid)
    readers:      PinboardStore.readersFor(@props.uuid)
    followers:    PinboardStore.followersFor(@props.uuid)
    roles:        RoleStore.rolesOn(@props.uuid, 'Pinboard')
    owner:        PinboardStore.userCursorFor(@props.uuid)

  getInitialState: ->
    @getStateFromStores()


  renderHeader: (title) ->
    <header>
      { title }
    </header>


  renderName: ->
    <input
      type        = "text"
      value       = { @state.attributes.get('title', '') }
      placeholder = "Please name the pinboard"
      onChange    = { @handleChange.bind(null, 'title') }
      onBlur      = { @handleBlur }
      onKeyDown   = { @handleKeyDown }
    />


  renderDescription: ->
    <input
      type        = "text"
      value       = { @state.attributes.get('description', '') }
      placeholder = "Please describe the pinboard"
      onChange    = { @handleChange.bind(null, 'description') }
      onBlur      = { @handleBlur }
      onKeyDown   = { @handleKeyDown }
    />


  renderInputs: ->
    <fieldset className="settings">

      <header className="cloud">
        Pinboard Settings
      </header>

      <ul>
        <li className="name">
          { @renderName() }
        </li>
        <li className="description">
          { @renderDescription() }
        </li>
        <li className="access-rights">
          { AccessRights.map(@renderAccessRightsItem).toArray() }
        </li>
      </ul>

    </fieldset>


  renderAccessRightsItem: (title, key) ->
    <label key={ key }>
      <input
        name      = "access_rights"
        type      = "radio"
        value     = { key }
        onChange  = { @handleAccessRightsChange }
        checked   = { @state.attributes.get('access_rights') == key }
      />
      <span>
        { title }
      </span>
    </label>


  renderAccessRights: ->
    <fieldset>
      { AccessRights.map(@renderAccessRightsItem).toArray() }
    </fieldset>


  render: ->
    return null unless @cursor.pinboard.deref(false)

    <section className="cloud-columns">
      <section className="cloud-column">
        <form onSubmit={ @handleSubmit } className="pinboard-settings">
          { @renderInputs() }
        </form>
      </section>
    </section>
