# @cjsx React.DOM


GlobalState     = require('global_state/state')


PinboardStore   = require('stores/pinboard_store')
RoleStore       = require('stores/role_store.cursor')
PinStore        = require('stores/pin_store')
UserStore       = require('stores/user_store.cursor')
TokenStore      = require('stores/token_store.cursor')


ModalHeader     = require('components/shared/modal_header')
ModalStack      = require('components/modal_stack')
InsightContent  = require('components/pinnable/insight_content')
UnicornChooser  = require('components/unicorn_chooser')
StandardButton  = require('components/form/buttons').StandardButton

KnownAttributes = Immutable.Seq(['user_id', 'parent_id', 'pinboard_id', 'pinnable_id', 'pinnable_type', 'content', 'pinboard_title', 'pinboard_description', 'origin'])


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
            tokens,
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


  highlightContent: ->
    textarea = @getDOMNode().querySelector('label.comment')
    snabbt(textarea, 'attention', {
      position: [50, 0, 0],
      springConstant: 2.4,
      springDeceleration: 0.9
    })

  handleSubmit: (event) ->
    event.preventDefault()

    return unless @state.attributes.get('user_id', false)

    unless @state.attributes.get('parent_id')
      unless @state.attributes.get('content')
        @highlightContent()
        return false


    system_pinboard_ids = PinboardStore.system().keySeq()
    pinboard_id         = @state.attributes.get('pinboard_id')
    user_id             = @state.attributes.get('user_id')

    if (pinboard_id == 'new')
      PinboardStore.create({ title: @state.attributes.get('pinboard_title'), description: @state.attributes.get('pinboard_description'), user_id: user_id })
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
    delete attributes['pinboard_id'] unless attributes['pinboard_id']
    delete attributes['pinnable_id'] unless attributes['pinnable_id']
    delete attributes['pinnable_type'] unless attributes['pinnable_type']

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
    pinboard = (if @props.parent_id then @getParentPinboard(id)) || @gatherPinboards(id).first()

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

  getParentPinboard: (id) ->
    return null unless (parentPin = @props.cursor.pins
      .filter (pin) => pin.get('uuid') == @props.parent_id
      .first())

    return null unless (parentPinboard = @props.cursor.pinboards
      .filter (pinboard) -> pinboard.get('uuid') == parentPin.get('pinboard_id')
      .first())

    @gatherPinboards(id).filter((pinboard) -> pinboard.get('title') == parentPinboard.get('title')).first()

  hasRepins: (id) ->
    PinStore
      .filter (pin) -> pin.get('parent_id') == id
      .size


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

    pinboards = pinboards.concat [<option key="new" value="new">Create collection</option>]

    pinboards


  renderPinboardSelect: ->
    <label className="pinboard">
      <div className="title">Collection</div>
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
          placeholder = "Enter collection name"
        />
      </div>
    </label>


  renderPinboardDescriptionInput: ->
    return null unless @state.attributes.get('pinboard_id') == 'new'

    <label className="pinboard">
      <div className="title" />
      <div className="input-wrapper">
        <input
          className   = "form-control"
          value       = { @state.attributes.get('pinboard_description') }
          onChange    = { @handleChange.bind(@, 'pinboard_description') }
          placeholder = "Enter collection description"
        />
      </div>
    </label>


  renderPinOrigin: ->
    return null if !@isCurrentUserSystemEditor() || @props.parent_id

    <label className="origin">
      <div className="title">Origin</div>
      <div className="input-wrapper">
        <input
          onChange  = { @handleChange.bind(@, 'origin') }
          value     = { @state.attributes.get('origin', '') }
        />
      </div>
    </label>

  renderPinCommentCounter: ->
    return null unless !@props.uuid || @isCurrentUserSystemEditor()

    content = @state.attributes.get('content') || ''

    <div className="counter">
      { @getContentMaxLength() - content.length }
    </div>

  renderPinCommentInput: ->
    content = @state.attributes.get('content') || ''

    if !@props.uuid || @isCurrentUserSystemEditor()
      <textarea
        rows      = 5
        onChange  = { @handleChange.bind(@, 'content') }
        value     = { content } />
    else
      <p>{ content }</p>

  renderPinComment: ->
    content = @state.attributes.get('content') || ''
    return null if @props.uuid and content.length == 0 && !@isCurrentUserSystemEditor()

    <label className="comment">
      <div className="title">
        { if @props.parent_id then "Note" else "Insight" }
        { @renderPinCommentCounter() }
      </div>
      { @renderPinCommentInput() }
    </label>


  renderDeleteButton: ->
    return null unless @props.uuid
    return null if !@state.attributes.get('pinnable_id') && @hasRepins(@props.uuid)

    <button key="delete" type="button" className="cc alert" onClick={ @handleDelete }>Delete</button>


  renderFooter: ->
    submitButtonTitle = if @props.uuid then 'Update' else 'Save It'

    <footer>
      <div>
        <button key="cancel" type="button" className="cc cancel" onClick={ @props.onCancel }>Cancel</button>
        { @renderDeleteButton() }
      </div>
      <button key="submit" type="submit" disabled={ not @state.attributes.get('user_id', false) } className="cc">{ submitButtonTitle }</button>
    </footer>


  render: ->
    return null unless @fetchDone()

    <form className="pin" onSubmit={ @handleSubmit }>
      <StandardButton
        className = "close transparent"
        iconClass = "cc-icon cc-times"
        type      = "button"
        onClick   = { @props.onCancel }/>

      <InsightContent
        withLinks   = { false }
        pin_id      = { @state.attributes.get('parent_id') }
        pinnable_id = { @state.attributes.get('pinnable_id') } />

      <fieldset>
        { @renderUserSelect() }
        { @renderPinboardSelect() }
        { @renderPinboardInput() }
        { @renderPinboardDescriptionInput() }
        { @renderPinComment() }
        { @renderPinOrigin() }
      </fieldset>

      { @renderFooter() }
    </form>
