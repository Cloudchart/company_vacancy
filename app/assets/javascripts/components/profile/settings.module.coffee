# @cjsx React.DOM


GlobalState     = require('global_state/state')

UserStore       = require('stores/user_store.cursor')
EmailStore      = require('stores/email_store')
TokenStore      = require('stores/token_store.cursor')

UserSyncApi     = require('sync/user_sync_api')

Emails          = require('components/profile/emails')
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
          User {
            emails,
            tokens
          }
        """

  propTypes:
    uuid: React.PropTypes.string.isRequired

  getInitialState: ->
    attributes: Immutable.Map()
    errors:     Immutable.Map()
    fetchDone:  false
    isSyncing:  false

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

  getUserEmails: ->
    @cursor.emails.filter (email) =>
      email.get('user_id') == @props.uuid
    .map (email) -> email.toObject()
    .toArray()

  getEmailUserTokens: ->
    @cursor.tokens.filter (token) =>
      token.get('name') == 'email_verification' && 
      token.get('owner_id') == @props.uuid &&
      token.get('owner_type') == 'User'
    .map (token) -> 
      token = token.toObject()
      token.data = token.data.toObject()
      token      
    .toArray()


  # Handlers
  #
  handleChange: (name, event) ->
    value       = event.target.value
    attributes  = @state.attributes

    @setState
      attributes: attributes.set(name, value)
      errors:     @state.errors.set(name, [])

  handleAvatarChange: (file) ->
    @setState
      attributes: @state.attributes.withMutations (attributes) ->
        attributes.remove('remove_avatar').set('avatar', file).set('avatar_url', URL.createObjectURL(file))
  
  handleAvatarRemove: ->
    @setState
      attributes: @state.attributes.withMutations (attributes) ->
        attributes.remove('avatar').remove('avatar_url').set('remove_avatar', true)

  handleSubmit: (event) ->
    event.preventDefault()

    @setState(isSyncing: true)

    UserSyncApi.update(@cursor.user, @state.attributes.toJSON()).then @handleSubmitDone, @handleSubmitFail

  handleSubmitDone: ->
    @setState(isSyncing: false)

  handleSubmitFail: (reason) ->
    @setState
      errors:    Immutable.Map(reason.responseJSON.errors)
      isSyncing: false

  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor = 
      user:   UserStore.cursor.items.cursor(@props.uuid)
      emails: EmailStore.cursor.items
      tokens: TokenStore.cursor.items

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
      title    = 'Full Name'
      errors   = { @state.errors.get('full_name') }
      onChange = { @handleChange.bind(@, 'full_name') }
      value    = { @state.attributes.get('full_name') } />

  renderOccupationInput: ->
    <Field  
      title    = 'Occupation'
      errors   = { @state.errors.get('occupation') }
      onChange = { @handleChange.bind(@, 'occupation') }
      value    = { @state.attributes.get('occupation') } />

  renderCompanyInput: ->
    <Field  
      title    = 'Company'
      errors   = { @state.errors.get('company') }
      onChange = { @handleChange.bind(@, 'company') }
      value    = { @state.attributes.get('company') } />

  renderSubmitButton: ->
    <footer>
      <div></div>
      <SyncButton 
        className = 'cc'
        sync      = @state.isSyncing
        type      = 'submit'
        text      = 'Update settings' />
    </footer>

  renderEmails: ->
    <Emails 
      emails              = { @getUserEmails() }
      verification_tokens = { @getEmailUserTokens() } />


  render: ->
    return null unless @isLoaded()

    <form className="settings" onSubmit={ @handleSubmit } >
      <fieldset>
        { @renderAvatar() }
        { @renderFullNameInput() }
        { @renderOccupationInput() }
        { @renderCompanyInput() }
      </fieldset>
      { @renderSubmitButton() }
      { @renderEmails() }
    </form>
