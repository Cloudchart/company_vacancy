# @cjsx React.DOM


GlobalState     = require('global_state/state')

UserStore       = require('stores/user_store.cursor')

UserSyncApi     = require('sync/user_sync_api')

PersonAvatar    = require('components/shared/person_avatar')
Field           = require('components/form/field')
SyncButton      = require('components/form/buttons').SyncButton


KnownAttributes = Immutable.Seq(['full_name', 'occupation', 'company', 'avatar_url'])


module.exports  = React.createClass

  # Component specifications
  #
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:
      user: ->
        """
          User {}
        """

  propTypes:
    uuid: React.PropTypes.string.isRequired

  getInitialState: ->
    attributes: Immutable.Map()
    fetchDone:  false

  fetch: ->
    GlobalState.fetch(@getQuery('user'), id: @props.uuid).then =>
      @handleFetchDone()


  # Helpers
  #
  isLoaded: ->
    @state.fetchDone

  handleFetchDone: ->
    @setState
      fetchDone:  true
      attributes: @getAttributesFromCursor()

  getAttributesFromCursor: ->
    Immutable.Map().withMutations (attributes) =>
      KnownAttributes.forEach (name) =>
        attributes.set(name, @state.attributes.get(name) || @cursor.user.get(name, ''))


  # Handlers
  #
  handleChange: (name, event) ->
    value       = event.target.value
    attributes  = @state.attributes

    @setState
      attributes: attributes.set(name, value)

  handleAvatarChange: (file) ->
    @setState
      attributes: @state.attributes.withMutations (attributes) ->
        attributes.remove('remove_avatar').set('avatar', file).set('avatar_url', URL.createObjectURL(file))
  
  handleAvatarRemove: ->
    @setState
      attributes: @state.attributes.withMutations (attributes) ->
        attributes.remove('avatar').remove('avatar_url').set('remove_avatar', true)

  handleSubmitClick: (event) ->
    event.preventDefault()

    UserSyncApi.updateCurrentUser(@state.attributes.toJSON())


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor = 
      user: UserStore.cursor.items.cursor(@props.uuid)

    @fetch()


  # Renderers
  #
  renderAvatar: ->
    <PersonAvatar
      avatarURL =  @state.attributes.get('avatar_url')
      onChange  =  @handleAvatarChange
      onRemove  =  @handleAvatarRemove
      value     =  @state.attributes.get('full_name') />

  renderFullNameInput: ->
    <Field  
      onChange = { @handleChange.bind(@, 'full_name') }
      value    = { @state.attributes.get('full_name') } />

  renderOccupationInput: ->
    <Field  
      onChange = { @handleChange.bind(@, 'occupation') }
      value    = { @state.attributes.get('occupation') } />

  renderCompanyInput: ->
    <Field  
      onChange = { @handleChange.bind(@, 'company') }
      value    = { @state.attributes.get('company') } />

  renderSubmitButton: ->
    <SyncButton 
      onClick = { @handleSubmitClick }
      text    = 'Update settings' />


  render: ->
    return null unless @isLoaded()

    <form className="settings">
      { @renderAvatar() }
      <fieldset>
        { @renderFullNameInput() }
        { @renderOccupationInput() }
        { @renderCompanyInput() }
        { @renderSubmitButton() }
      </fieldset>
    </form>
