# @cjsx React.DOM


GlobalState   = require('global_state/state')


PinboardStore = require('stores/pinboard_store')
RoleStore     = require('stores/role_store.cursor')
PinStore      = require('stores/pin_store')
UserStore     = require('stores/user_store.cursor')


ModalActions  = require('actions/modal_actions')


InsightContent  = require('components/pinnable/insight_content')
UnicornChooser  = require('components/unicorn_chooser')
StandardButton  = require('components/form/buttons').StandardButton


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
            pinboards,
            writable_pinboards
          }

        """


      user: ->
        """
          User {
            roles,
            pinboards,
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
    GlobalState.fetch(@getQuery('viewer'))


  fetchSystemPinboards: ->
    GlobalState.fetch(@getQuery('system_pinboards'))


  fetchUser: (id) ->
    if id
      GlobalState.fetch(@getQuery('user'), id: id).then => @setState({})
    else
      GlobalState.fetch(@getQuery('viewer')).then => @setState({})


  fetchPin: ->
    if @props.uuid
      promise = GlobalState.fetch(@getQuery('pin'), id: @props.uuid).then =>
        @fetchUser(@props.cursor.pins.getIn([@props.uuid, 'user_id']))
    else
      @fetchUser()


  fetch: ->
    Promise.all([@fetchSystemPinboards(), @fetchPin()]).then =>
      @handleFetchDone()


  handleFetchDone: ->
    @setState
      fetchDone:  true
      attributes: @getAttributesFromCursor()


  fetchDone: ->
    @state.fetchDone == true


  handleSubmit: (event) ->
    event.preventDefault()

    return unless @state.attributes.get('user_id', false)

    system_pinboard_ids = PinboardStore.system().keySeq()
    pinboard_id         = @state.attributes.get('pinboard_id')
    user_id             = @state.attributes.get('user_id')

    if (pinboard_id == 'new')
      PinboardStore.create({ title: @state.attributes.get('pinboard_title'), user_id: user_id })
        .then(@handlePinboardSave, @handleSaveFail)

    else if system_pinboard_ids.contains(pinboard_id)
      PinboardStore.create({ title: @props.cursor.pinboards.getIn([pinboard_id, 'title']), user_id: user_id })
        .then(@handlePinboardSave, @handleSaveFail)

    else
      attributes = @state.attributes.remove('pinboard_title').toJSON()
      @savePin(attributes)


  handleDelete: (event) ->
    event.preventDefault()

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

    if name == 'content' and value.length > (contentMaxLength = @getContentMaxLength())
      value = value.substring(0, contentMaxLength)

    if name == 'user_id'
      attributes = attributes.set('pinboard_id', @getDefaultPinboardId(value))

    @setState
      attributes: attributes.set(name, value)


  handleUserIdChange: (user_id) ->
    if user_id
      @fetchUser(user_id).then =>
        @handleChange('user_id', { target: { value: user_id } })
    else
      @setState
        attributes: @state.attributes.set('user_id', null)



  gatherPinboards: (id = @state.attributes.get('user_id')) ->
    pinboards         = PinboardStore.writableBy(id)

    pinboard_names    = pinboards
      .map (item) ->
        item.get('title')
      .toSetSeq()

    system_pinboards  = PinboardStore.system()
      .filterNot (item) ->
        pinboard_names.contains(item.get('title'))

    pinboards.concat(system_pinboards)
      .sortBy (item) ->
        item.get('title')


  getDefaultPinboardId: (id) ->
    pinboard = @gatherPinboards(id).first()

    if pinboard then pinboard.get('uuid') else 'new'


  getContentMaxLength: ->
    if @isSelectedUserUnicorn() then 500 else 140


  getAttributesFromCursor: ->
    pin = @props.cursor.pins.cursor(@props.uuid)

    Immutable.Map().withMutations (attributes) =>
      KnownAttributes.forEach (name) =>
        attributes.set(name, @state.attributes.get(name) || pin.get(name, ''))

      unless attributes.get('user_id', false)
        attributes.set('user_id', @props.cursor.me.get('uuid'))

      unless attributes.get('pinboard_id', false)
        attributes.set('pinboard_id', @getDefaultPinboardId(attributes.get('user_id')))


  getAttributesFromProps: ->
    Immutable.Map().withMutations (attributes) =>
      KnownAttributes.forEach (name) =>
        attributes.set(name, @props[name] || '')


  isUserWithRole: (userId, roleValue) ->
    RoleStore.rolesFor(userId)
      .find (role) =>
        role.get('owner_id',    null)   is null     and
        role.get('owner_type',  null)   is null     and
        role.get('value')               is roleValue


  isCurrentUserSystemEditor: ->
    @isUserWithRole(UserStore.me().get('uuid'), 'editor')


  isSelectedUserUnicorn: ->
    @isUserWithRole(@state.attributes.get('user_id'), 'unicorn')


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
    attributes: @getAttributesFromProps()


  # Renderers
  #
  renderHeader: ->
    <header>
      <h1>Pin this to your pinboard</h1>
      <StandardButton 
        className  = "close-button transparent"
        onClick    = { @props.onCancel }
        iconClass  = "cc-icon cc-times" />
    </header>

  renderUserSelect: ->
    return null unless  @isCurrentUserSystemEditor()
    return null if      @props.parent_id

    <label className="user">
      <span className="title">Author</span>
      <UnicornChooser
        value         = { @state.attributes.get('user_id') }
        defaultValue  = { @props.cursor.me.get('uuid') }
        onChange      = { @handleUserIdChange }
      />
    </label>

  renderPinboardSelectOptions: ->
    pinboards = @gatherPinboards()
      .map (pinboard, uuid) ->
        <option key={ uuid } value={ uuid }>{ pinboard.get('title') }</option>
      .valueSeq()

    if @isCurrentUserSystemEditor()
      pinboards = pinboards.concat [<option key="new" value="new">Create Category</option>]

    pinboards


  renderPinboardSelect: ->
    <label className="pinboard">
      <div className="title">Category</div>
      <div className="select-wrapper">
        <select
          value     = { @state.attributes.get('pinboard_id') }
          onChange  = { @handleChange.bind(@, 'pinboard_id') }
        >
          { @renderPinboardSelectOptions().toArray() }
        </select>
        <i className="fa fa-angle-down select-icon" />
      </div>
    </label>


  renderPinboardInput: ->
    return null unless @state.attributes.get('pinboard_id') == 'new'

    <label className="pinboard">
      <div className="title" />
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
      <div className="title">
        { if @props.parent_id then "Note" else "Insight" }
        <div className="counter">
          { @getContentMaxLength() - @state.attributes.get('content').length }
        </div>
      </div>
      <textarea
        rows      = 5
        onChange  = { @handleChange.bind(@, 'content') }
        value     = { @state.attributes.get('content', '') }
      />
    </label>


  renderDeleteButton: ->
    return null unless @props.uuid
    return null unless @isCurrentUserSystemEditor()

    <button key="delete" type="button" className="cc alert" onClick={ @handleDelete }>Delete</button>


  renderFooter: ->
    submitButtonTitle = if @props.uuid then 'Update' else 'Pin It'

    <footer>
      <div>
        <button key="cancel" type="button" className="cc alert" onClick={ @props.onCancel }>Cancel</button>
        { @renderDeleteButton() }
      </div>
      <button key="submit" type="submit" disabled={ not @state.attributes.get('user_id', false) } className="cc">{ submitButtonTitle }</button>
    </footer>


  render: ->
    return null unless @fetchDone()

    <form className="pin" onSubmit={ @handleSubmit }>
      { @renderHeader() }

      <InsightContent 
        withLinks = { false }
        type      = { if @state.attributes.get('parent_id') then 'pin' else 'post' }
        uuid      = { if @state.attributes.get('parent_id') then @state.attributes.get('parent_id') }
        post_id   = { @state.attributes.get('pinnable_id') } />

      <fieldset>
        { @renderUserSelect() }
        { @renderPinboardSelect() }
        { @renderPinboardInput() }
        { @renderPinComment() }
      </fieldset>

      { @renderFooter() }
    </form>
