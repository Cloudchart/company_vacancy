# @cjsx React.DOM

GlobalState = require('global_state/state')
Constants = require('constants')


# Stores
#
PinStore    = require('stores/pin_store')
UserStore   = require('stores/user_store.cursor')


# Components
#
Human = require('components/human')
InsightOrigin = require('components/insight/origin')
PinButton = require('components/pinnable/pin_button')
EditPinButton = require('components/pinnable/edit_pin_button')
ApprovePinButton = require('components/pinnable/approve_pin_button')
StandardButton = require('components/form/buttons').StandardButton

ShareInsightButton = require('components/insight/share_button')


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


  getDefaultProps: ->
    showHotzone: true

  gatherAttributes: ->
    uuid:           @getInsight().get('uuid')
    parent_id:      @getInsight().get('parent_id')
    pinnable_id:    @props.cursor.pin.get('pinnable_id')
    pinnable_type:  @props.cursor.pin.get('pinnable_type')

  getStateFromStores: ->
    user: @props.cursor.users.cursor(@getInsight().get('user_id'))

  onGlobalStateChange: ->
    @setState @getStateFromStores()

  getInitialState: ->
    @getStateFromStores()

  isSuggested: ->
    @props.cursor.pin.get('is_suggestion')

  getInsight: ->
    if @isSuggested()
      PinStore.cursor.items.cursor(@props.cursor.pin.get('parent_id'))
    else
      @props.cursor.pin

  destroySuggestion: ->
    PinStore.destroy(@props.cursor.pin.get('uuid')) if confirm('Are you sure?')

  getOrigin: ->
    @getInsight().get('origin')

  getContent: ->
    content = @getInsight().get('content')

    if @getOrigin() then trimDots(content) else content


  # Helpers
  #
  # getSomathing: ->


  # Lifecycle methods
  #
  # componentWillMount: ->


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
    return null if @isSuggested()
    <ApprovePinButton uuid = { @props.uuid } />

  renderEditButton: ->
    return null if @isSuggested()
    <EditPinButton uuid={ @props.uuid } />

  renderButtons: (insight) ->
    <ul className="round-buttons">
      { @renderApproveButton() }
      { @renderEditButton() }
      <ShareInsightButton pin = { @props.cursor.pin.deref().toJS() } shouldFetch = false />
      <PinButton {...@gatherAttributes()} title={ insight.get('content') } showHotzone = { @props.showHotzone } />
    </ul>

  renderSuggestionDeleteButton: ->
    return null unless UserStore.isEditor()

    <StandardButton
      className = "transparent"
      iconClass = "cc-icon cc-times"
      onClick   = { @destroySuggestion }
    />

  renderSuggestion: ->
    return null unless @isSuggested()

    <section className="suggestion">
      <i className="svg-icon svg-cloudchart-logo" />
      Suggested by { Constants.SITE_NAME }
      { @renderSuggestionDeleteButton() }
    </section>


  render: ->
    return null unless @props.cursor.pin.deref(false)
    return null unless @state.user.deref(false)

    insight = @getInsight()

    insightClasses = cx
      insight:    true
      item:       true
      unapproved: !insight.get('is_approved')
      suggested:  @isSuggested()

    <article className = { insightClasses } >
      <Human
        uuid            = { insight.get('user_id') }
        showUnicornIcon = { true }
        type            = "user" />
      { @renderContent() }
      { @renderSuggestion() }
      { @renderButtons(insight) }
    </article>
