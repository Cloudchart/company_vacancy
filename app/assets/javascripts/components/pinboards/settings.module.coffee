# @cjsx React.DOM

GlobalState = require('global_state/state')

PinboardStore = require('stores/pinboard_store')
UserStore     = require('stores/user_store.cursor')
RoleStore     = require('stores/role_store.cursor')

ModalStack = require('components/modal_stack')
InviteForm = require('components/pinboards/invite_form')
InsightsImporter = require('components/pinboards/insights_importer')

Fields = Immutable.Seq(['title', 'description', 'access_rights', 'suggestion_rights', 'tag_names'])

AccessRights = Immutable.Seq
  public:     'Open to everyone'
  protected:  'Invite-only'
  private:    'Private'

SuggestionRights = Immutable.Seq
  anyone: 'Anyone can suggest'
  editors: 'Only editors can suggest'


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
            roles,
            edges {
              tag_names
            }
          }
        """

      viewer: ->
        """
          Viewer {
            edges {
              is_editor
            }
          }
        """


  # Component Specifications
  #
  getInitialState: ->
    @getStateFromStores()

  onGlobalStateChange: ->
    @setState @getStateFromStores()

  getStateFromStores: ->
    attributes:   @getAttributesFromCursor()
    editors:      PinboardStore.editorsFor(@props.uuid)
    readers:      PinboardStore.readersFor(@props.uuid)
    followers:    PinboardStore.followersFor(@props.uuid)
    roles:        RoleStore.rolesOn(@props.uuid, 'Pinboard')
    owner:        PinboardStore.userCursorFor(@props.uuid)


  # Lifecycle Methods
  #
  componentWillMount: ->
    @cursor =
      pinboard: PinboardStore.cursor.items.cursor(@props.uuid)
      viewer: UserStore.me()

  componentDidMount: ->
    @fetch().then => @setState(ready: true)


  # Fetchers
  #
  fetch: ->
    Promise.all([
      @fetchPinboard(),
      @fetchViewer()
    ])

  fetchPinboard: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.uuid }).then =>
      @setState @getStateFromStores()

  fetchViewer: ->
    GlobalState.fetch(@getQuery('viewer'))


  # Helpers
  #
  save: ->
    return unless Fields.some (name) =>
      @state.attributes.get(name) isnt @cursor.pinboard.get(name)

    PinboardStore.update(@props.uuid, @state.attributes.toJS())

  getAttributesFromCursor: ->
    Fields
      .reduce (memo, name) =>
        memo.set(name, @cursor.pinboard.get(name)) if @cursor
        memo
      , Immutable.Map().asMutable()
      .asImmutable()


  # Handlers
  #
  handleSubmit: (event) ->
    event.preventDefault()
    @save()

  handleChange: (name, event) ->
    @setState
      attributes: @state.attributes.set(name, event.target.value)

  handleBlur: (event) ->
    @save()

  handleKeyDown: (event) ->
    return unless event.key == 'Enter'
    event.target.blur()

  handleRightsChange: (name, event) ->
    @setState
      attributes: @state.attributes.set(name, event.target.value)

    clearTimeout @__rightsSyncTimeout
    @__rightsSyncTimeout = setTimeout @save, 250

  handleImportInsightsButtonClick: (event) ->
    ModalStack.show(<InsightsImporter pinboard = { @props.uuid } />)


  # Renderers
  #
  renderHeader: (title) ->
    <header>
      { title }
    </header>

  renderName: ->
    <input
      className   = "cc-input"
      type        = "text"
      maxLength   = { 100 }
      value       = { @state.attributes.get('title', '') }
      placeholder = "Please name the pinboard"
      onChange    = { @handleChange.bind(null, 'title') }
      onBlur      = { @handleBlur }
      onKeyDown   = { @handleKeyDown } />

  renderDescription: ->
    <input
      className   = "cc-input"
      type        = "text"
      maxLength   = { 250 }
      value       = { @state.attributes.get('description', '') }
      placeholder = "What's this collection about?"
      onChange    = { @handleChange.bind(null, 'description') }
      onBlur      = { @handleBlur }
      onKeyDown   = { @handleKeyDown } />

  renderTagNames: ->
    return null unless @cursor.viewer.get('is_editor')

    <li className="tags">
      <input
        className = 'cc-input'
        type = 'text'
        value = { @state.attributes.get('tag_names', '') }
        placeholder = 'Assign few keywords'
        onChange = { @handleChange.bind(null, 'tag_names') }
        onBlur = { @handleBlur }
        onKeyDown = { @handleKeyDown }
      />
    </li>

  renderInputs: ->
    <fieldset className="settings">

      <ul>
        <li className="name">
          { @renderName() }
        </li>
        <li className="description">
          { @renderDescription() }
        </li>

        { @renderTagNames() }

        <li className="access-rights">
          { AccessRights.map(@renderAccessRightsItem).toArray() }
        </li>
        <li className="access-rights">
          { SuggestionRights.map(@renderSuggestionRightsItem).toArray() }
        </li>
      </ul>

    </fieldset>

  renderAccessRightsItem: (title, key) ->
    <label key={ key }>
      <input
        name      = "access_rights"
        type      = "radio"
        value     = { key }
        onChange  = { @handleRightsChange.bind(@, 'access_rights') }
        checked   = { @state.attributes.get('access_rights') == key } />
      <span>
        { title }
      </span>
    </label>

  renderSuggestionRightsItem: (title, key) ->
    <label key={ key }>
      <input
        name      = "suggestion_rights"
        type      = "radio"
        value     = { key }
        onChange  = { @handleRightsChange.bind(@, 'suggestion_rights') }
        checked   = { @state.attributes.get('suggestion_rights') == key } />
      <span>
        { title }
      </span>
    </label>

  renderImportInsightsButton: ->
    return null unless @cursor.viewer.get('is_editor')

    <button className="cc" onClick={ @handleImportInsightsButtonClick }>
      Import insights from another collection
    </button>


  # Main render
  #
  render: ->
    return null unless @cursor.pinboard.deref(false) && @state.ready

    <section className="cloud-columns">
      <section className="cloud-column">
        <form onSubmit={ @handleSubmit } className="pinboard-settings">
          { @renderInputs() }
        </form>
        { @renderImportInsightsButton() }
      </section>
    </section>
