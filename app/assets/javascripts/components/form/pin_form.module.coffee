# @cjsx React.DOM


GlobalState   = require('global_state/state')


PinboardStore = require('stores/pinboard_store')
RoleStore     = require('stores/role_store.cursor')
PinStore      = require('stores/pin_store')
UserStore     = require('stores/user_store.cursor')


ModalActions  = require('actions/modal_actions')

# Constants
#
ContentMaxLength = 500


KnownAttributes = Immutable.Seq(['user_id', 'parent_id', 'pinboard_id', 'pinnable_id', 'pinnable_type', 'content', 'pinboard_title'])


# Utils
#
titleRE = /^(?:<div>)?([^<]+)(?:<\/div>)?$/


unwrapTitle = (title) ->
  (titleRE.exec(title) || [title, ''])[1]


# Exports
#
module.exports = React.createClass


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:

    queries:
      viewer: ->
        """
          Viewer {
            roles,
            writable_pinboards
          }

        """

      unicorns: ->
        """
          Unicorns {
            roles,
            writable_pinboards
          }

        """

      system_pinboards: ->
        """
          SystemPinboards {}
        """

      pin: ->
        """
          Pin {}

        """


  fetchViewer: ->
    GlobalState.fetch(@getQuery('viewer')).then =>
      if @currentUserIsSystemEditor()
        @fetchUnicorns()
        @setState
          loaders: @state.loaders.set('viewer', true)
      else
        @setState
          loaders: @state.loaders.set('viewer', true).set('unicorns', true)


  fetchSystemPinboards: ->
    GlobalState.fetch(@getQuery('system_pinboards')).then =>
      @setState
        loaders: @state.loaders.set('system_pinboards', true)


  fetchPin: ->
    if @props.uuid
      GlobalState.fetch(@getQuery('pin'), id: @props.uuid).then =>
        @setState
          loaders: @state.loaders.set('pin', true)
    else
      @setState
        loaders: @state.loaders.set('pin', true)


  fetchUnicorns: ->
    GlobalState.fetch(@getQuery('unicorns')).then =>
      @setState
        loaders: @state.loaders.set('unicorns', true)


  fetch: ->
    @fetchViewer()
    @fetchSystemPinboards()
    @fetchPin()


  fetchDone: ->
    @state.loaders.get('viewer') and
    @state.loaders.get('unicorns') and
    @state.loaders.get('system_pinboards') and
    @state.loaders.get('pin')


  handleSubmit: (event) ->
    event.preventDefault()

    if (@state.attributes.get('pinboard_id') == 'new')
      PinboardStore.create({ title: @state.attributes.get('pinboard_title') }).then(@handlePinboardSave, @handleSaveFail)
    else
      attributes = @state.attributes.remove('pinboard_title').toJSON()
      @savePin(attributes)


  handleDelete: (event) ->
    event.preventDefault()

    if confirm('Are you sure?')
      if confirm('Are you really sure?')
        PinStore.destroy(@props.uuid).then(@props.onDone, @handleSaveFail)


  savePin: (attributes) ->
    delete attributes['pinboard_title']
    delete attributes['parent_id'] unless attributes['parent_id']

    if @props.uuid
      PinStore.update(@props.uuid, attributes).then(@props.onDone, @handleSaveFail)
    else
      PinStore.create(attributes).then(@props.onDone, @handleSaveFail)


  handlePinboardSave: (json) ->
    attributes = @state.attributes
      .remove('pinboard_title')
      .set('pinboard_id', json.id)
      .toJSON()

    @savePin(attributes)


  handleSaveFail: ->


  handleChange: (name, event) ->
    value       = event.target.value
    attributes  = @state.attributes

    if name == 'content' and value.length > ContentMaxLength
      value = value.substring(0, ContentMaxLength)

    if name == 'user_id'
      attributes = attributes.set('pinboard_id', @getDefaultPinboardIdFor(value))

    @setState
      attributes: attributes.set(name, value)


  getDefaultUserId: ->
    if @props.uuid then @props.cursor.pins.items.getIn([@props.uuid, 'user_id']) else @props.cursor.me.get('uuid', '')


  getDefaultPinboardIdFor: (user_id) ->
    defaultPinboard = @props.cursor.pinboards
      .filter (pinboard) =>
        pinboard.get('user_id') == user_id or
        pinboard.get('user_id') == null

      .sortBy (pinboard) -> pinboard.get('title')
      .first()

    if defaultPinboard then defaultPinboard.get('uuid') else 'new'


  setAttributes: ->
    attributes  = Immutable.Map({})
    pin         = @props.cursor.pins.cursor(@props.uuid)

    attributes  = attributes.withMutations (attributes) =>
      KnownAttributes.forEach (name) =>
        attributes.set(name, pin.get(name, @props[name] || ''))

      unless attributes.get('pinboard_id')
        attributes.set('pinboard_id', @getDefaultPinboardIdFor(@getDefaultUserId()))

      unless attributes.get('user_id')
        attributes.set('user_id', @getDefaultUserId())

      attributes

    attributes


  # Lifecycle
  #

  componentDidMount: ->
    @fetch()


  getDefaultProps: ->
    title:        ''
    cursor:
      pinboards:    PinboardStore.cursor.items
      users:        UserStore.cursor.items
      roles:        RoleStore.cursor.items
      pins:         PinStore.cursor.items
      me:           UserStore.me()


  getInitialState: ->
    loaders:    Immutable.Map()
    attributes: @setAttributes()


  # Render
  #

  renderHeader: ->
    <header>
      <div>Pin It</div>
      <div className="title">{ unwrapTitle(@props.title) }</div>
    </header>


  renderUserSelectOptions: ->
    UserStore

      .unicorns()

      .valueSeq()

      .concat([UserStore.me().deref({})])

      .filterNot (user) =>
        @props.cursor.pins
          .find (pin) =>
            pin.get('pinnable_type')  is @props.pinnable_type and
            pin.get('pinnable_id')    is @props.pinnable_id   and
            pin.get('user_id')        is user.get('uuid')

      .toSet()

      .map (user) =>
        uuid = user.get('uuid')
        <option key={ uuid } value={ uuid }>{ user.get('first_name') + ' ' + user.get('last_name') }</option>


  currentUserIsSystemEditor: ->
    RoleStore.rolesFor(UserStore.me().get('uuid'))
      .find (role) =>
        role.get('owner_id',    null)   is null     and
        role.get('owner_type',  null)   is null     and
        role.get('value')               is 'editor'


  renderUserSelect: ->
    return null unless  @currentUserIsSystemEditor()
    return null if      @props.parent_id

    disabled = !!@props.uuid and @props.cursor.me.get('uuid') isnt @state.attributes.get('user_id')

    <label className="user">
      <span className="title">Choose an author</span>
      <div className="select-wrapper">
        <select
          value     = { @state.attributes.get('user_id') }
          onChange  = { @handleChange.bind(@, 'user_id') }
          disabled  = { disabled }
        >
          { @renderUserSelectOptions().toArray() }
        </select>
        <i className="fa fa-angle-down select-icon" />
      </div>
    </label>


  renderPinboardSelectOptions: ->
    options = @props.cursor.pinboards
      .filter (pinboard) =>
        pinboard.get('user_id') == @state.attributes.get('user_id') or
        pinboard.get('user_id') == null

      .sortBy (pinboard) -> pinboard.get('title')

      .map (pinboard, uuid) ->
        <option key={ uuid } value={ uuid }>{ pinboard.get('title') }</option>

      .toList()

    if @state.attributes.get('user_id') == @props.cursor.me.get('uuid')
      options = options.push(<option key="new" value="new">Create Category</option>)

    options


  renderPinboardSelect: ->
    <label className="pinboard">
      <span className="title">Pick a Category</span>
      <div className="select-wrapper">
        <select
          value     ={ @state.attributes.get('pinboard_id') }
          onChange  ={ @handleChange.bind(@, 'pinboard_id') }
        >
          { @renderPinboardSelectOptions().toArray() }
        </select>
        <i className="fa fa-angle-down select-icon" />
      </div>
    </label>


  renderPinboardInput: ->
    return null unless @state.attributes.get('pinboard_id') == 'new'

    <label className="pinboard">
      <span className="title" />
      <div className="input-wrapper">
        <input
          className   = "form-control"
          autoFocus   = "true"
          value       = { @state.attributes.get('pinboard_title') }
          onChange    = { @handleChange.bind(@, 'pinboard_title') }
          placeholder = "Pick a name"
        />
      </div>
    </label>


  renderPinComment: ->
    <label className="comment">
      <span className="title">Add Comments</span>
      <textarea
        rows      = 5
        onChange  = { @handleChange.bind(@, 'content') }
        value     = { @state.attributes.get('content', '') }
      />
      <span className="counter">{ ContentMaxLength - @state.attributes.get('content').length }</span>
    </label>



  renderDeleteButton: ->
    return null unless @props.uuid
    return null unless @currentUserIsSystemEditor()

    <button key="delete" type="button" className="cc alert" onClick={ @handleDelete }>Delete</button>


  renderFooter: ->
    submitButtonTitle = if @props.uuid then 'Update' else 'Pin It'

    <footer>
      <div>
        <button key="cancel" type="button" className="cc cancel" onClick={ @props.onCancel }>Cancel</button>
        { @renderDeleteButton() }
      </div>
      <button key="submit" type="submit" className="cc">{ submitButtonTitle }</button>
    </footer>


  render: ->
    return null unless @fetchDone()

    <form className="pin" onSubmit={ @handleSubmit }>
      { @renderHeader() }

      <fieldset>
        { @renderUserSelect() }
        { @renderPinboardSelect() }
        { @renderPinboardInput() }
        { @renderPinComment() }
      </fieldset>

      { @renderFooter() }
    </form>
