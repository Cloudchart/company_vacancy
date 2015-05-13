# @cjsx React.DOM

GlobalState = require('global_state/state')

UserStore    = require('stores/user_store.cursor')
EmailStore   = require('stores/email_store')
TokenStore   = require('stores/token_store.cursor')
LandingStore = require('stores/landing_store')

LandingSyncApi = require('sync/landing_sync_api')
UserSyncApi    = require('sync/user_sync_api')

Emails = require('components/profile/emails')
Field = require('components/form/field')
SyncButton = require('components/form/buttons').SyncButton
Checkbox = require('components/form/checkbox')
ContentEditableArea = require('components/form/contenteditable_area')

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
            landings {
              author
            },
            emails,
            tokens
          }
        """

  propTypes:
    uuid:       React.PropTypes.string.isRequired

  getDefaultProps: ->
    cursor:
      tokens:   TokenStore.cursor.items
      landings: LandingStore.cursor.items

  getInitialState: ->
    attributes:  Immutable.Map()
    errors:      Immutable.Map()
    formUpdated: false
    fetchDone:   false
    statusIcon:  ''
    submitText:  'Update settings'
    sync:        Immutable.Map()

  fetch: (options = {}) ->
    GlobalState.fetch(@getQuery('user'), _.extend(options, id: @props.uuid)).then =>
      @handleFetchDone()

  onGlobalStateChange: ->
    @setState refreshed_at: + new Date


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

  isEditorUpdatingUnicorn: ->
    @props.uuid isnt @cursor.me.get('uuid') and UserStore.isEditor() and UserStore.isUnicorn(@cursor.user)

  getGreeting: ->
    TokenStore.findByUserAndName(@cursor.user, 'greeting')

  getInputClass: (name) ->
    if @state.errors.has(name) && @state.errors.get(name).length > 0 then 'cc-input error' else 'cc-input'

  getLandings: ->
    LandingStore.filter (landing) =>
      landing.get('user_id') == @cursor.user.get('uuid')


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

    @setState(sync: @state.sync.set('personal', true))

    UserSyncApi.update(@cursor.user, @state.attributes.toJSON()).then @handleSubmitDone, @handleSubmitFail

  handleSubmitDone: ->
    @fetch(force: true)

    @setState
      sync:        @state.sync.set('personal', false)
      formUpdated: false
      statusIcon:  'fa fa-check'
      submitText:  'Updated'

  handleSubmitFail: (reason) ->
    @setState
      errors:      Immutable.Map(reason.responseJSON.errors)
      formUpdated: false
      statusIcon:  'fa fa-times'
      sync:        @state.sync.set('personal', false)
      submitText:  'Update failed'

  handleSubscriptionChange: (checked) ->
    if checked
      UserSyncApi.subscribe(@cursor.user).then =>
        GlobalState.fetch(new GlobalState.query.Query("Viewer{tokens}"), { force: true })
    else
      UserSyncApi.unsubscribe(@cursor.user).then =>
        @clearSubscriptionTokens()
        GlobalState.fetch(new GlobalState.query.Query("Viewer{tokens}"), { force: true })

  handleGreetingChange: (value) ->
    greeting = @getGreeting()

    if value and greeting
      TokenStore.updateGreeting(greeting.get('uuid'), content: value)
    else if value and !greeting
      TokenStore.createGreeting(@cursor.user, content: value)
    else if !value and greeting
      TokenStore.destroyGreeting(greeting.get('uuid'))

  handleCreateLandingClick: ->
    @setState sync: @state.sync.set('landing', true)

    LandingSyncApi.create(@cursor.user).then @handleCreateLandingDone, @handleCreateLandingFail

  handleCreateLandingDone: (data) ->
    LandingStore.fetchOne(data.id).then (json) =>
      @setState sync: @state.sync.set('landing', false)

      location.href = json.landing.url

  handleCreateLandingFail: ->
    @setState sync: @state.sync.set('landing', false)


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor = 
      user:   UserStore.cursor.items.cursor(@props.uuid)
      me:     UserStore.me()
      emails: EmailStore.cursor.items
      tokens: TokenStore.cursor.items

    @fetch()


  # Renderers
  #
  renderFullNameInput: ->
    <input  
      placeholder = 'Full Name'
      className   = { @getInputClass('full_name') }
      onChange    = { @handleChange.bind(@, 'full_name') }
      value       = { @state.attributes.get('full_name') } />

  renderOccupationInput: ->
    <input  
      placeholder  = 'Job Title'
      className    = { @getInputClass('occupation') }
      onChange     = { @handleChange.bind(@, 'occupation') }
      value        = { @state.attributes.get('occupation') } />

  renderCompanyInput: ->
    <input  
      placeholder  = 'Company'
      className    = { @getInputClass('company') }
      onChange     = { @handleChange.bind(@, 'company') }
      value        = { @state.attributes.get('company') } />

  renderTwitterHandle: ->
    return null unless @isEditorUpdatingUnicorn()

    <input  
      placeholder  = 'Twitter'
      className    = { @getInputClass('twitter') }
      onChange     = { @handleChange.bind(@, 'twitter') }
      value        = { @state.attributes.get('twitter') } />

  renderSubmitButton: ->
    <footer>
      <div></div>
      <SyncButton 
        className = 'cc'
        iconClass = { if @state.formUpdated then '' else @state.statusIcon }
        disabled  = !@state.formUpdated
        sync      = @state.sync.get('personal')
        type      = 'submit'
        text      = @state.submitText />
    </footer>

  renderEmails: ->
    return null unless @props.uuid is @cursor.me.get('uuid')

    <Emails 
      emails              = { @getUserEmails() }
      verification_tokens = { @getEmailUserTokens() } />

  renderSubscription: ->
    return null unless @props.uuid is @cursor.me.get('uuid')

    <section className="subscription">
      <h2>Subscriptions</h2>
      <Checkbox
        checked  = { @isSubscribed() } 
        onChange = { @handleSubscriptionChange }>
        Our weekly newsletter
      </Checkbox>
    </section>

  renderLandingPages: ->
    return null unless (landings = @getLandings()).size

    <ul>
      {
        landings.map (landing) ->
          author = UserStore.cursor.items.cursor(landing.get('author_id')).deref(Immutable.Map())

          <li key = { landing.get('uuid') }>
            <a href={ landing.get('url') }>
              Personal landing page by { author.get('full_name') }
            </a>
          </li>
        .toArray()
      }
    </ul>

  renderLandingsControls: ->
    <section className="landings">
      { @renderLandingPages() }
      <SyncButton 
        className = "cc"
        onClick   = { @handleCreateLandingClick }
        sync      = { @state.sync.get('landing') }
        text      = "Create personal landing page" />
    </section>

  renderGreeting: ->
    return null unless @isEditorUpdatingUnicorn()

    greeting = @getGreeting()
    value = if greeting
      greeting.get('data').get('content')
    else
      null

    <ContentEditableArea
      onChange    = { @handleGreetingChange }
      placeholder = 'Tap to add message'
      readOnly    = { false }
      value       = { value } />

  renderInvitation: ->
    return null unless UserStore.isEditor()

    <section className="invitation-form">
      <h2>Invitation</h2>

      { @renderGreeting() }
      { @renderLandingsControls() }
    </section>


  # Main render
  # 
  render: ->
    return null unless @isLoaded()

    <section className="settings">
      { @renderInvitation() }
      <form onSubmit={ @handleSubmit }>
        <h2>Basic info</h2>
        { @renderFullNameInput() }
        { @renderOccupationInput() }
        { @renderCompanyInput() }
        { @renderTwitterHandle() }
        { @renderSubmitButton() }
      </form>
      { @renderEmails() }
      { @renderSubscription() }
    </section>
