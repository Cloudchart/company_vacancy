# @cjsx React.DOM

GlobalState    = require('global_state/state')
UserStore      = require('stores/user_store.cursor')

InviteSyncApi  = require('sync/invite_sync_api')

StandardButton = require('components/form/buttons').StandardButton
SyncButton     = require('components/form/buttons').SyncButton

Checkbox       = require('components/form/checkbox')

# Exports
#
module.exports = React.createClass

  displayName: 'InvitesApp'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:
      user: ->
        """
          User {
            system_roles
          }
        """

      viewer: ->
        """
          Viewer {
            system_roles
          }
        """

  getDefaultProps: ->
    cursor: UserStore.me()

  getInitialState: ->
    invitedUser:       Immutable.Map()
    progress:          null
    isInviteSyncing:   false
    isEmailSyncing:    false
    isLoaded:          false
    inviteAttributes:  Immutable.Map()
    inviteErrors:      Immutable.Map()
    emailAttributes:   Immutable.Map()
    emailErrors:       Immutable.Map()

  fetch: ->
    GlobalState.fetch(@getQuery('viewer')).then => @setState isLoaded: true


  # Helpers
  #
  isLoaded: ->
    @props.cursor.deref(false) && @state.isLoaded

  getDefaultEmailAttributes: (user=null) ->
    Immutable.Map(
      subject: "#{@props.cursor.get('first_name')} invited you to CloudChart"
      body:    "Hi, @#{user.get('twitter')}" if user
    )

  getInviterName: ->
    "#{@props.cursor.get('full_name')} (@#{@props.cursor.get('twitter')})"


  # Handlers
  #
  handleInviteInputChange: (name, event) ->
    if name == 'is_unicorn'
      value = event
    else  
      value = event.target.value
    
    inviteAttributes = @state.inviteAttributes

    @setState inviteAttributes: inviteAttributes.set(name, value)

  handleInviteSubmit: (event) ->
    event.preventDefault()

    @setState isInviteSyncing: true

    inviteAttributes = @state.inviteAttributes.set('is_unicorn', if @state.inviteAttributes.get('is_unicorn') then 1 else 0)

    InviteSyncApi.create(inviteAttributes).then @handleInviteSubmitDone, @handleInviteSubmitFail

  handleInviteSubmitDone: (data) ->
    GlobalState.fetch(@getQuery("user"), { id: data.id }).then =>
      user = UserStore.cursor.items.get(data.id)

      @setState
        progress:         "invite_sent"
        isInviteSyncing:  false
        inviteAttributes: Immutable.Map()
        inviteErrors:     Immutable.Map()
        emailAttributes:  @getDefaultEmailAttributes(user)
        invitedUser:      user

  handleInviteSubmitFail: (reason) ->
    @setState
      inviteErrors:     Immutable.Map(reason.responseJSON.errors)
      isInviteSyncing:  false

  handleEmailInputChange: (name, event) ->
    value            = event.target.value
    emailAttributes  = @state.emailAttributes

    @setState emailAttributes: emailAttributes.set(name, value)

  handleEmailSubmit: (event) ->
    event.preventDefault()

    @setState isEmailSyncing: true

    InviteSyncApi.send_email(@state.invitedUser, @state.emailAttributes).then @handleEmailSubmitDone, @handleEmailSubmitFail

  handleEmailSubmitDone: ->
    @setState
      progress:        "email_sent"
      isEmailSyncing:  false
      emailAttributes: @getDefaultEmailAttributes()
      emailErrors:     Immutable.Map()

  handleEmailSubmitFail: (reason) ->
    @setState
      emailErrors:      Immutable.Map(reason.responseJSON.errors)
      isEmailSyncing:   false

  handleEmailSkip: ->
    @setState
      progress:        "email_skipped"
      emailAttributes: @getDefaultEmailAttributes()
      emailErrors:     Immutable.Map()


  # Lifecycle methods
  #
  componentWillMount: ->
    @fetch() unless @isLoaded()


  # Renderers
  #
  renderInviteErrors: (key) ->
    return null unless @state.inviteErrors.has(key)

    <ul className="errors">
      {
        @state.inviteErrors.get(key).map (error) ->
          <li>{ error }</li>
      }
    </ul>

  renderEditorText: ->
    return null unless UserStore.isEditor() && UserStore.isUnicorn(@state.invitedUser)

    settingsUrl = @state.invitedUser.get('user_url') + '#settings'

    <span>
      You can add a <a href={ settingsUrl } target="_blank">personal greeting</a> and <a href={ settingsUrl } target="_blank">do a special landing page</a>.
    </span>

  renderText: ->
    switch @state.progress
      when "invite_sent"
        <section>
          <p>Great, now @{ @state.invitedUser.get('twitter') } has access to CloudChart. { @renderEditorText() } You can let them know yourself or send them an email:</p>
        </section>
      when "email_skipped", "email_sent"
        <section>
          <p>Well done!</p>
          <p>Invite more founders or unicorns:</p>
        </section>
      else
        <section>
          <p>We welcome fellow founders and unicorns to CloudChart community. If you know someone who's seeking knowledge or is eager to share it — feel free to send them an invite.</p>
          <p>Simply enter that person's Twitter handle and we'll send them an invitation.</p>
        </section>

  renderUnicornCheckbox: ->
    return null unless UserStore.isEditor()

    <Checkbox
      checked   = { @state.inviteAttributes.get('is_unicorn', false) }
      onChange  = { @handleInviteInputChange.bind(@, 'is_unicorn') } >
      That's a unicorn
    </Checkbox>

  renderInviteInput: ->
    return null if @state.progress == "invite_sent"

    <form className="invite" onSubmit={ @handleInviteSubmit }>
      <label className="cc-input-label">
        <input 
          className   = { if @state.inviteErrors.has('twitter') || @state.inviteErrors.has('base') then 'cc-input error' else 'cc-input' }
          placeholder = '@twitter'
          onChange    = { @handleInviteInputChange.bind(@, 'twitter') }
          value       = { @state.inviteAttributes.get('twitter', '') }  />
        { @renderInviteErrors('base') }
        { @renderUnicornCheckbox() }
      </label>
      <SyncButton
        className   = "cc"
        sync        = { @state.isInviteSyncing }
        text        = "Invite"
        type        = "submit" />
    </form>

  renderEmailInput: ->
    return null unless @state.progress == "invite_sent"

    <form className="email" onSubmit = { @handleEmailSubmit } >
      <label>
        To:
        <input 
          className   = { if @state.emailErrors.has('email') then 'cc-input error' else 'cc-input' }
          placeholder = 'user@example.com'
          onChange    = { @handleEmailInputChange.bind(@, 'email') }
          value       = { @state.emailAttributes.get('email', '') } />
      </label>
      <label>
        Subject:
        <input 
          className   = { if @state.emailErrors.has('subject') then 'cc-input error' else 'cc-input' }
          placeholder = 'Subject goes here'
          onChange    = { @handleEmailInputChange.bind(@, 'subject') }
          value       = { @state.emailAttributes.get('subject', '') } />
      </label>
      <section className="content">
        <textarea
          className   = { if @state.emailErrors.has('body') then 'error' else null } 
          rows        = 3
          placeholder = 'Add a few words from yourself.'
          onChange    = { @handleEmailInputChange.bind(@, 'body') }
          value       = { @state.emailAttributes.get('body', '') } />
        <p>{ @props.email_copy.first_paragraph.replace('%{inviter_name}', @getInviterName()) }</p>
        <p>{ @props.email_copy.second_paragraph }</p>
        <ul>
          <li>{ @props.email_copy.first_item }</li>
          <li>{ @props.email_copy.second_item }</li>
          <li>{ @props.email_copy.third_item }</li>
        </ul>
        <p>Have questions? Suggestions? Doughnuts? Simply reply to this email or chat with <a href="https://twitter.com/cloudchartapp" target="_blank">@CloudChartApp</a> on Twitter.</p>
      </section>
      <section className="controls">
        <SyncButton
          className   = "cc"
          sync        = { @state.isEmailSyncing }
          text        = "Send email"
          type        = "submit" />
        <StandardButton
          className   = "transparent skip"
          text        = "Skip this step"
          onClick     = { @handleEmailSkip }
          type        = "button" />
      </section>
    </form>


  render: ->
    return null unless @isLoaded()

    <section className="invites">
      { @renderText() }
      { @renderEmailInput() }
      { @renderInviteInput() }
    </section>
