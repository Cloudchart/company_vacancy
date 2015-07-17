# @cjsx React.DOM

GlobalState       = require('global_state/state')

# Imports
#
PinboardStore     = require('stores/pinboard_store')
TokenStore        = require('stores/token_store.cursor')
UserStore         = require('stores/user_store.cursor')

Buttons           = require('components/form/buttons')
SyncButton        = Buttons.SyncButton
StandardButton    = Buttons.StandardButton

ModalStack        = require('components/modal_stack')



# Main
#
Component = React.createClass

  displayName: "RolesAccessRequest"

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      pinboard: ->
        """
          Pinboard {}
        """

      viewer: ->
        """
          Viewer {
            tokens_as_target
          }
        """

  propTypes:
    ownerId:       React.PropTypes.string.isRequired
    ownerType:     React.PropTypes.string.isRequired

  getInitialState: ->
    isSyncing:   false
    isLoaded:    false
    attributes:  Immutable.Map()

  getDefaultProps: ->
    cursor:
      viewer: UserStore.me()
      tokens: TokenStore.cursor.items

  fetch: ->
    Promise.all([
      GlobalState.fetch(@getQuery('pinboard'), { id: @props.ownerId }),
      GlobalState.fetch(@getQuery('viewer'))
    ])


  # Helpers
  #
  isLoaded: ->
    @state.isLoaded && @getViewer()

  getPinboard: ->
    PinboardStore.cursor.items.get(@props.ownerId)

  getViewer: ->
    @props.cursor.viewer.deref(false)

  isRequestSent: ->
    !!TokenStore.findAccessRequestByOwnerAndUser(@props.ownerId, @props.ownerType, @getViewer().get('uuid'))


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      pinboard: PinboardStore.cursor.items.cursor(@props.ownerId)

    @fetch().then => @setState isLoaded: true unless @isLoaded()


  # Handlers
  #
  handleInputChange: (name, event) ->
    @setState attributes: @state.attributes.set(name, event.target.value)

  handleSubmit: (event) ->
    event.preventDefault()

    @setState isSyncing: true

    PinboardStore
      .requestAccess(@getPinboard(), @state.attributes.get('message'))
      .then @handleSubmitDone, @handleSubmitFail

  handleSubmitDone: ->
    ModalStack.hide()

  handleSubmitFail: (reason) ->
    @setState
      errors:    Immutable.Map(reason.responseJSON.errors)
      isSyncing: false


  # Renderers
  #
  renderMessageInput: ->
    <label className="cc-input-label">
      <input
        className   = 'cc-input'
        placeholder = 'Tell us why should we let you in'
        onChange    = { @handleInputChange.bind(@, 'message') }
        value       = { @state.attributes.get('message', '') }  />
    </label>

  renderSentMessage: ->
    return null unless @isRequestSent()

    <section>
      <p>
        You've already requested invite for this collection, please wait for collection's owner response.
      </p>
      <StandardButton
        className = "cc"
        text      = "Got it!"
        onClick   = { ModalStack.hide } />
    </section>

  renderInviteForm: ->
    return null if @isRequestSent()

    <form onSubmit={ @handleSubmit } >
      { @renderMessageInput() }

      <SyncButton
        className = "cc"
        text      = "Send"
        sync      = { @state.isSyncing } />
    </form>


  render: ->
    return null unless @isLoaded()

    <section className="form-modal">
      <header>
        Request to join this invite-only collection
      </header>
      { @renderSentMessage() }
      { @renderInviteForm() }
    </section>


# Exports
#
module.exports = Component
