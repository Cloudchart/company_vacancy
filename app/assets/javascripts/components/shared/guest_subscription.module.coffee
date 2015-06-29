# @cjsx React.DOM

API         = require('push_api/subscription_push_api')
SyncButton  = require('components/form/buttons').SyncButton
cx          = React.addons.classSet

# Exports
#
module.exports = React.createClass

  displayName: 'GuestSubscription'


  handleChange: (event) ->
    @setState
      email:  event.target.value
      error:  false


  handleSubmit: (event) ->
    event.preventDefault()

    @setState
      sync: true

    API.subscribe_guest(@state.email).then(@done, @fail)


  done: ->
    @setState
      is_subscribed: true

    null


  fail: ->
    @setState
      sync:   false
      error:  true

    @refs['email'].getDOMNode().focus()

    snabbt(@refs['form'].getDOMNode(), 'attention', {
      position: [50, 0, 0],
      springConstant: 2.4,
      springDeceleration: 0.9
    })

    null


  getInitialState: ->
    email:          ''
    sync:           false
    error:          false
    is_subscribed:  false


  renderText: ->
    <p>
      { if @state.is_subscribed then "Thanks! We’ll keep you posted." else @props.text }
    </p>


  renderForm: ->
    return null if @state.is_subscribed

    inputClassName = cx
      'cc-input': true
      'error':    @state.error

    <form ref="form" onSubmit={ @handleSubmit }>
      <input ref="email" type="email" className={ inputClassName } placeholder="Please enter your email" value={ @state.email } onChange={ @handleChange } />
      <SyncButton
        className   = "cc"
        text        = "Subscribe"
        sync        = { @state.sync }
        type        = "submit"
      />
    </form>


  render: ->
    <section className="subscription">
      { @renderText() }
      { @renderForm() }
    </section>
