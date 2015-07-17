# @cjsx React.DOM

# Imports
#
GlobalState = require('global_state/state')
# Constants = require('constants')

PinStore = require('stores/pin_store')
UserStore = require('stores/user_store.cursor')

Human = require('components/human')
InsightOrigin = require('components/insight/origin')
PinButton = require('components/pinnable/pin_button')
EditPinButton = require('components/pinnable/edit_pin_button')
ApprovePinButton = require('components/pinnable/approve_pin_button')
ShareInsightButton = require('components/insight/share_button')
InsightSuggestion = require('components/insight/suggestion')


# Utils
#
cx = React.addons.classSet
trimDots = require('utils/trim_string').trimDots


# Exports
#
module.exports = React.createClass

  displayName: 'InsightItem'

  mixins: [GlobalState.mixin]

  statics:
    getCursor: (id) ->
      pin:    PinStore.cursor.items.cursor(id)
      users:  UserStore.cursor.items


  # Component Specifications
  #
  getDefaultProps: ->
    showHotzone: true

  getInitialState: ->
    @getStateFromStores()

  onGlobalStateChange: ->
    @setState @getStateFromStores()

  getStateFromStores: ->
    user: @props.cursor.users.cursor(@getInsight().get('user_id'))


  # Helpers
  #
  gatherAttributes: ->
    uuid:           @getInsight().get('uuid')
    parent_id:      @getInsight().get('parent_id')
    pinnable_id:    @props.cursor.pin.get('pinnable_id')
    pinnable_type:  @props.cursor.pin.get('pinnable_type')

  isSuggestion: ->
    @props.cursor.pin.get('is_suggestion')

  getInsight: ->
    if @isSuggestion()
      PinStore.cursor.items.cursor(@props.cursor.pin.get('parent_id'))
    else
      @props.cursor.pin

  getOrigin: ->
    @getInsight().get('origin')

  getContent: ->
    content = @getInsight().get('content')
    if @getOrigin() then trimDots(content) else content


  # Renderers
  #
  renderOrigin: ->
    return null unless (pin = @getInsight())
    <InsightOrigin pin = { pin.deref().toJS() } />

  renderContent: ->
    <section className="content">
      { @getContent() }
      { @renderOrigin() }
    </section>

  renderApproveButton: ->
    return null if @isSuggestion()
    <ApprovePinButton uuid = { @props.uuid } />

  renderEditButton: ->
    return null if @isSuggestion()
    <EditPinButton uuid={ @props.uuid } />

  renderButtons: (insight) ->
    <ul className="round-buttons">
      { @renderApproveButton() }
      { @renderEditButton() }
      <ShareInsightButton pin = { @props.cursor.pin.deref().toJS() } shouldFetch = false />
      <PinButton {...@gatherAttributes()} title={ insight.get('content') } showHotzone = { @props.showHotzone } />
    </ul>


  # Main render
  #
  render: ->
    return null unless @props.cursor.pin.deref(false)
    return null unless @state.user.deref(false)

    insight = @getInsight()

    insightClasses = cx
      insight:    true
      item:       true
      unapproved: !insight.get('is_approved')

    <article className = { insightClasses } >
      <Human
        uuid            = { insight.get('user_id') }
        showUnicornIcon = { true }
        type            = "user" />
      { @renderContent() }

      <InsightSuggestion pin = { @props.cursor.pin.deref().toJS() } />

      { @renderButtons(insight) }
    </article>
