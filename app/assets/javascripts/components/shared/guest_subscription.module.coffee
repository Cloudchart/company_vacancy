# @cjsx React.DOM

SyncButton = require('components/form/buttons').SyncButton

# Exports
#
module.exports = React.createClass

  displayName: 'GuestSubscription'


  handleChange: (event) ->
    @setState
      email: event.target.value


  handleSubmit: (event) ->
    event.preventDefault()

    @setState
      sync: true


  getInitialState: ->
    email:  ''
    sync:   false


  renderForm: ->
    <form onSubmit={ @handleSubmit }>
      <input type="email" className="cc-input" placeholder="Please enter your email" value={ @state.email } onChange={ @handleChange } />
      <SyncButton
        className   = "cc"
        text        = "Subscribe"
        sync        = { @state.sync }
        type        = "submit"
      />
    </form>


  render: ->
    <section className="subscription">
      <p>
        { @props.text }
      </p>
      { @renderForm() }
    </section>
