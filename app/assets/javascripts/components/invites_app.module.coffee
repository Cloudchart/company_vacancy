# @cjsx React.DOM

GlobalState    = require('global_state/state')
UserStore      = require('stores/user_store.cursor')

InviteSyncApi  = require('sync/invite_sync_api')

StandardButton = require('components/form/buttons').StandardButton
SyncButton     = require('components/form/buttons').SyncButton

# Exports
#
module.exports = React.createClass

  displayName: 'InvitesApp'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:
      user: ->
        """
          User {}
        """

  getDefaultProps: ->
    cursor: UserStore.me()

  getInitialState: ->
    invitedUser:       Immutable.Map()
    progress:          null
    isInviteSyncing:   false
    isEmailSyncing:    false
    inviteAttributes:  Immutable.Map()
    inviteErrors:      Immutable.Map()
    emailAttributes:   Immutable.Map()
    emailErrors:       Immutable.Map()


  # Helpers
  #
  isLoaded: ->
    @props.cursor.deref(false)

  getDefaultEmailAttributes: ->
    Immutable.Map(subject: "#{@props.cursor.get('first_name')} invited you to CloudChart")


  # Handlers
  #
  handleInviteInputChange: (name, event) ->
    value            = event.target.value
    inviteAttributes = @state.inviteAttributes

    @setState inviteAttributes: inviteAttributes.set(name, value)

  handleInviteSubmit: (event) ->
    event.preventDefault()

    @setState isInviteSyncing: true

    InviteSyncApi.create(@state.inviteAttributes).then @handleInviteSubmitDone, @handleInviteSubmitFail

  handleInviteSubmitDone: (data) ->
    GlobalState.fetch(@getQuery("user"), { id: data.id }).then =>
      user = UserStore.cursor.items.get(data.id)

      @setState
        progress:         "invite_sent"
        isInviteSyncing:  false
        inviteAttributes: Immutable.Map()
        inviteErrors:     Immutable.Map()
        emailAttributes:  @getDefaultEmailAttributes()
        invitedUser:      user

  handleInviteSubmitFail: (reason) ->
    @setState
      inviteErrors:     Immutable.Map(reason.responseJSON.errors).keySeq()
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
      emailErrors:      Immutable.Map(reason.responseJSON.errors).keySeq()
      isEmailSyncing:   false

  handleEmailSkip: ->
    @setState
      progress:        "email_skipped"
      emailAttributes: @getDefaultEmailAttributes()
      emailErrors:     Immutable.Map()


  # Renderers
  #
  renderText: ->
    switch @state.progress
      when "invite_sent"
        <section>
          <p>Great, now @{ @state.invitedUser.get('twitter') } has access to CloudChart. You can let them know yourself or send them an email:</p>
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

  renderInviteInput: ->
    return null if @state.progress == "invite_sent"

    <form className="invite" onSubmit={ @handleInviteSubmit }>
      <input 
        className   = { if @state.inviteErrors.contains('twitter') then 'cc-input error' else 'cc-input' }
        placeholder = '@twitter'
        onChange    = { @handleInviteInputChange.bind(@, 'twitter') }
        value       = { @state.inviteAttributes.get('twitter', '') }  />
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
          className   = { if @state.emailErrors.contains('email') then 'cc-input error' else 'cc-input' }
          placeholder = 'user@example.com'
          type        = 'email'
          onChange    = { @handleEmailInputChange.bind(@, 'email') }
          value       = { @state.emailAttributes.get('email', '') } />
      </label>
      <label>
        Subject:
        <input 
          className   = { if @state.emailErrors.contains('subject') then 'cc-input error' else 'cc-input' }
          placeholder = 'Subject goes here'
          onChange    = { @handleEmailInputChange.bind(@, 'subject') }
          value       = { @state.emailAttributes.get('subject', '') } />
      </label>
      <section className="content">
        <p>{ @props.email_copy.greeting }</p>
        <textarea
          className   = { if @state.emailErrors.contains('body') then 'error' else null } 
          rows        = 3
          placeholder = 'Add a few words from yourself.'
          onChange    = { @handleEmailInputChange.bind(@, 'body') }
          value       = { @state.emailAttributes.get('body', '') } />
        <p>{ @props.email_copy.first_paragraph }</p>
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
