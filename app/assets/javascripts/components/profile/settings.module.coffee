# @cjsx React.DOM


GlobalState     = require('global_state/state')

UserStore       = require('stores/user_store.cursor')
EmailStore      = require('stores/email_store')
TokenStore      = require('stores/token_store.cursor')

UserSyncApi     = require('sync/user_sync_api')

Emails          = require('components/profile/emails')
Field           = require('components/form/field')
SyncButton      = require('components/form/buttons').SyncButton
Checkbox        = require('components/form/checkbox')


KnownAttributes = Immutable.Seq(['full_name', 'occupation', 'company', 'twitter'])


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
    uuid:       React.PropTypes.string.isRequired
    withEmails: React.PropTypes.bool

  getDefaultProps: ->
    cursor:
      tokens: TokenStore.cursor.items
    withEmails: false

  getInitialState: ->
    attributes:  Immutable.Map()
    errors:      Immutable.Map()
    formUpdated: false
    fetchDone:   false
    statusIcon:  ''
    submitText:  'Update settings'
    isSyncing:   false

  fetch: (options = {}) ->
    GlobalState.fetch(@getQuery('user'), _.extend(options, id: @props.uuid)).then =>
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
        attributes.set(name, @state.attributes.get(name) || @cursor.user.get(name, '') || '')

  getUserEmails: ->
    @cursor.emails.filter (email) =>
      email.get('user_id') == @props.uuid
    .map (email) -> email.toObject()
    .toArray()

  getEmailUserTokens: ->
    @props.cursor.tokens.filter (token) =>
      token.get('name') == 'email_verification' && 
      token.get('owner_id') == @props.uuid &&
      token.get('owner_type') == 'User'
    .map (token) -> 
      token = token.toObject()
      token.data = token.data.toObject()
      token      
    .toArray()

  isSubscribed: ->
    !!@props.cursor.tokens.filter (token) =>
      token.get('owner_id') == @props.uuid &&
      token.get('name') == 'subscription'
    .size

  clearSubscriptionTokens: ->
    @props.cursor.tokens.forEach (item, id) =>
      if item.get('owner_id') == @props.uuid &&
         item.get('name') == 'subscription'
        TokenStore.cursor.items.removeIn(id)


  # Handlers
  #
  handleChange: (name, event) ->
    value       = event.target.value
    attributes  = @state.attributes

    @setState
      formUpdated: true
      submitText:  'Update settings'
      attributes:  attributes.set(name, value)
      errors:      @state.errors.set(name, [])

  handleSubmit: (event) ->
    event.preventDefault()

    @setState(isSyncing: true)

    UserSyncApi.update(@cursor.user, @state.attributes.toJSON()).then @handleSubmitDone, @handleSubmitFail

  handleSubmitDone: ->
    @fetch(force: true)

    @setState
      isSyncing:   false
      formUpdated: false
      statusIcon:  'fa fa-check'
      submitText:  'Updated'

  handleSubmitFail: (reason) ->
    @setState
      errors:      Immutable.Map(reason.responseJSON.errors)
      formUpdated: false
      statusIcon:  'fa fa-times'
      isSyncing:   false
      submitText:  'Update failed'

  handleSubscriptionChange: (checked) ->
    if checked
      UserSyncApi.subscribe(@cursor.user).then =>
        GlobalState.fetch(new GlobalState.query.Query("Viewer{tokens}"), { force: true })
    else
      UserSyncApi.unsubscribe(@cursor.user).then =>
        @clearSubscriptionTokens()
        GlobalState.fetch(new GlobalState.query.Query("Viewer{tokens}"), { force: true })



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

  renderTwitterHandle: ->
    return null unless @props.uuid isnt UserStore.me().get('uuid') and
      UserStore.isEditor() and UserStore.isUnicorn(@cursor.user)

    <Field  
      title    = 'Twitter'
      errors   = { @state.errors.get('twitter') }
      onChange = { @handleChange.bind(@, 'twitter') }
      value    = { @state.attributes.get('twitter') } />

  renderSubmitButton: ->
    <footer>
      <div></div>
      <SyncButton 
        className = 'cc'
        iconClass = { if @state.formUpdated then '' else @state.statusIcon }
        disabled  = !@state.formUpdated
        sync      = @state.isSyncing
        type      = 'submit'
        text      = @state.submitText />
    </footer>

  renderEmails: ->
    return null unless @props.withEmails

    <Emails 
      emails              = { @getUserEmails() }
      verification_tokens = { @getEmailUserTokens() } />

  renderSubscription: ->
    <section className="subscription">
      <h2>Subscriptions</h2>
      <Checkbox
        checked  = { @isSubscribed() } 
        onChange = { @handleSubscriptionChange }>
        Subscribe me
      </Checkbox>
    </section>


  render: ->
    return null unless @isLoaded()

    <form className="settings" onSubmit={ @handleSubmit } >
      <fieldset>
        { @renderFullNameInput() }
        { @renderOccupationInput() }
        { @renderCompanyInput() }
        { @renderTwitterHandle() }
      </fieldset>
      { @renderSubmitButton() }
      { @renderEmails() }
      { @renderSubscription() }
    </form>
