# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinboardStore = require('stores/pinboard_store')
UserStore     = require('stores/user_store.cursor')
RoleStore     = require('stores/role_store.cursor')


# Components
#
UserRole = require('components/pinboards/settings/user_role')


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
    PinboardStore.update(@props.uuid, @state.attributes.toJS())


  handleSubmit: (event) ->
    event.preventDefault()
    @save()


  handleChange: (name, event) ->
    @setState
      attributes: @state.attributes.set(name, event.target.value)


  handleBlur: (event) ->
    return unless Fields.some (name) =>
      @state.attributes.get(name) isnt @cursor.pinboard.get(name)


  handleKeyDown: (event) ->
    return unless event.key == 'Enter'
    event.target.blur()


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


  getInitialState: ->
    @getStateFromStores()


  renderHeader: (title) ->
    <header>
      { title }
    </header>


  renderAccessRightsItem: (title, key) ->
    <label key={ key }>
      <input
        name      = "access_rights"
        type      = "radio"
        value     = { key }
        onChange  = { @handleChange.bind(null, 'access_rights') }
        checked   = { @state.attributes.get('access_rights') == key }
      />
      { title }
    </label>


  renderAccessRights: ->
    <fieldset>
      { AccessRights.map(@renderAccessRightsItem).toArray() }
    </fieldset>


  renderInputs: ->
    <fieldset>
      <label>
        <input
          type        = "text"
          value       = { @state.attributes.get('title', '') }
          placeholder = "Please name the pinboard"
          onChange    = { @handleChange.bind(null, 'title') }
          onBlur      = { @handleBlur }
          onKeyDown   = { @handleKeyDown }
        />
      </label>
      <br />
      <label>
        <input
          type        = "text"
          value       = { @state.attributes.get('description', '') }
          placeholder = "Please describe the pinboard"
          onChange    = { @handleChange.bind(null, 'description') }
          onBlur      = { @handleBlur }
          onKeyDown   = { @handleKeyDown }
        />
      </label>
    </fieldset>


  renderOwner: ->
    owner = UserStore.cursor.items.cursor(@cursor.pinboard.get('user_id'))

    <tr>
      <td>
        { owner.get('full_name') }
      </td>
      <td>
        Owner
      </td>
    </tr>


  renderEditors: ->
    people = @state.editors.concat(@state.readers).concat(@state.followers)

    people
      .map (user) =>
        role = @state.roles.find (role) -> role.get('user_id') == user.get('uuid')
        <UserRole key={ role.get('uuid') } user={ user } role={ role } />


  renderPeople: ->
    <table>
      <tbody>
        { @renderOwner() }
        { @renderEditors().toArray() }
      </tbody>
    </table>


  renderFooter: ->
    <footer>
      <button>Execute</button>
    </footer>


  render: ->
    return null unless @cursor.pinboard.deref(false)

    <form onSubmit={ @handleSubmit } className="pinboard-settings">
      { @renderHeader('Pinboard Settings') }
      { @renderInputs() }
      { @renderAccessRights() }
      { @renderHeader('Security') }
      { @renderPeople() }
      { @renderFooter() }
    </form>
