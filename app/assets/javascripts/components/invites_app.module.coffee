# @cjsx React.DOM

GlobalState    = require('global_state/state')
UserStore      = require('stores/user_store.cursor')

StandardButton = require('components/form/buttons').StandardButton  


# Exports
#
module.exports = React.createClass

  displayName: 'InvitesApp'

  mixins: [GlobalState.mixin]

  getDefaultProps: ->
    cursor: UserStore.me()

  getInitialState: ->
    twitter:          ""
    progress:         null
    inviteAttributes: Immutable.Map()
    emailAttributes:  Immutable.Map()


  # Helpers
  #
  isLoaded: ->
    @props.cursor.deref(false)

  getDefaultEmailAttributes: ->
    Immutable.Map(subject: "#{@props.cursor.get('first_name')} invited you to CloudChart")


  # Handlers
  #
  handleEmailInputChange: (name, event) ->
    value            = event.target.value
    emailAttributes  = @state.emailAttributes

    @setState emailAttributes: emailAttributes.set(name, value)

  handleInviteInputChange: (name, event) ->
    value            = event.target.value
    inviteAttributes = @state.inviteAttributes

    @setState inviteAttributes: inviteAttributes.set(name, value)

  handleEmailSubmit: (event) ->
    event.preventDefault()

    @setState
      progress:        "email_sent"
      emailAttributes: @getDefaultEmailAttributes()

  handleEmailSkip: ->
    @setState progress: "email_skipped"

  handleInviteSubmit: (event) ->
    event.preventDefault()

    @setState
      progress:         "invite_sent"
      twitter:          @state.inviteAttributes.get('twitter')
      inviteAttributes: Immutable.Map()
      emailAttributes:  @getDefaultEmailAttributes()


  # Renderers
  #
  renderText: ->
    switch @state.progress
      when "invite_sent"
        <section>
          <p>Great, now @{ @state.twitter } has access to CloudChart. You can let them know yourself or send them an email:</p>
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
        className   = 'cc-input'
        placeholder = '@twitter'
        onChange    = { @handleInviteInputChange.bind(@, 'twitter') }
        value       = { @state.inviteAttributes.get('twitter', '') }  />
      <StandardButton
        className   = "cc"
        text        = "Invite"
        type        = "submit" />
    </form>

  renderEmailInput: ->
    return null unless @state.progress == "invite_sent"

    <form className="email" onSubmit = { @handleEmailSubmit } >
      <label>
        To:
        <input 
          className   = 'cc-input'
          placeholder = 'user@example.com'
          type        = 'email'
          onChange    = { @handleEmailInputChange.bind(@, 'email') }
          value       = { @state.emailAttributes.get('email', '') } />
      </label>
      <label>
        Subject:
        <input 
          className   = 'cc-input'
          placeholder = 'Subject goes here'
          onChange    = { @handleEmailInputChange.bind(@, 'subject') }
          value       = { @state.emailAttributes.get('subject', '') } />
      </label>
      <section className="content">
        <p>Hi,</p>
        <textarea 
          rows        = 3
          placeholder = 'Add a few words from yourself.'
          onChange    = { @handleEmailInputChange.bind(@, 'content') }
          value       = { @state.emailAttributes.get('content', '') } />
        <p>You have been invited to CloudChart, an educational tool designed for founders. At CloudChart, we create unicorn companies' timelines that contain actionable insights by successful founders, investors and experts. Explore their success stories, and use the insights to grow your own business.</p>
        <p>Log in with your Twitter account. Take a really short and helpful tour to unleash the whole power of CloudChart, or start using it right away:</p>
        <ul>
          <li>browse unicorns' timelines to see how they came to life and grew.</li>
          <li>discover actionable insights by founders, investors, and experts and use them to grow your business.</li>
          <li>follow companies you're interested in to get their updates and learn from their successes and failures.</li>
        </ul>
        <p>Have questions? suggestions? doughnuts? Simply reply to this email or chat with @cloudchartapp on Twitter.</p>
      </section>
      <section className="controls">
        <StandardButton
          className   = "cc"
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
