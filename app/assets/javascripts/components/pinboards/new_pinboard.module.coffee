# @cjsx React.DOM

PinboardStore  = require('stores/pinboard_store')

SyncButton     = require('components/form/buttons').SyncButton


# Exports
#
module.exports = React.createClass

  displayName: 'NewPinboard'

  propTypes:
    user_id:  React.PropTypes.string.isRequired

  getInitialState: ->
    isSyncing:   false
    attributes:  Immutable.Map(user_id: this.props.user_id)


  # Handlers
  #
  handleInputChange: (name, event) ->
    @setState attributes: @state.attributes.set(name, event.target.value)

  handleSubmit: (event) ->
    event.preventDefault()

    @setState isSyncing: true

    PinboardStore
      .create(@state.attributes.toJSON())
      .then @handleSubmitDone, @handleSubmitFail

  handleSubmitDone: (json) ->
    PinboardStore.fetchOne(json.id).then =>
      pinboard = PinboardStore.cursor.items.get(json.id)

      location.href = pinboard.get('url')

  handleSubmitFail: (reason) ->
    @setState
      errors:    Immutable.Map(reason.responseJSON.errors)
      isSyncing: false


  # Lifecycle methods
  #
  renderTitleInput: ->
    <label className="cc-input-label">
      <input
        className   = 'cc-input'
        placeholder = 'Collection name'
        onChange    = { @handleInputChange.bind(@, 'title') }
        value       = { @state.attributes.get('title', '') }  />
    </label>

  renderForm: ->
    <form onSubmit={ @handleSubmit } >
      { @renderTitleInput() }

      <SyncButton
        className = "cc"
        text      = "Create"
        sync      = { @state.isSyncing } />
    </form>


  # Renderers
  #
  render: ->
    <section className="form-modal">
      <header>
        Name your collection
      </header>
      { @renderForm() }
    </section>
