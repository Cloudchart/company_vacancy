# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinStore    = require('stores/pin_store')
UserStore   = require('stores/user_store.cursor')


# Components
#
Human             = require('components/human')
PinButton         = require('components/pinnable/pin_button')
EditPinButton     = require('components/pinnable/edit_pin_button')
ApprovePinButton  = require('components/pinnable/approve_pin_button')
Tooltip           = require('components/shared/tooltip')


# Utils
#
cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'InsightItem'

  mixins: [GlobalState.mixin]

  statics:
    getCursor: (id) ->
      pin:    PinStore.cursor.items.cursor(id)
      users:  UserStore.cursor.items


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
    @props.cursor.pin

  getInsight: ->
    if @isSuggested()
      PinStore.getParentFor(@props.cursor.pin.get('uuid'))
    else
      @props.cursor.pin


  # Helpers
  #
  isLink: (string) ->
    /^https?:\/\/.*/.test(string)


  # Renderers
  #
  renderOriginIcon: ->
    <i className="fa fa-code" />

  renderOrigin: ->
    return null unless (origin = @getInsight().get('origin'))

    if @isLink(origin)
      <a className="origin" href={ origin } target="_blank">
        { @renderOriginIcon() }
      </a>
    else
      <Tooltip 
        className      = "origin"
        element        = { @renderOriginIcon() }
        tooltipContent = { origin } />
      

  renderContent: ->
    <section className="content">
      { @getInsight().get('content') }
      { " " }
      { @renderOrigin() }
    </section>

  renderApproveButton: ->
    return null if @isSuggested()

    <ApprovePinButton uuid = { @props.uuid } />

  renderEditButton: ->
    return null if @isSuggested()

    <EditPinButton uuid={ @props.uuid } />

  renderButtons: ->
    <ul className="round-buttons">
      { @renderApproveButton() }
      { @renderEditButton() }
      <PinButton {...@gatherAttributes()} title={ @getInsight().get('content') } />
    </ul>

  renderSuggestion: ->
    return null unless @isSuggested()

    <section className="suggestion">
      Suggested by CloudChart
    </section>


  render: ->
    return null unless @props.cursor.pin.deref(false)
    return null unless @state.user.deref(false)

    insightClasses = cx
      insight:    true
      item:       true
      unapproved: !@getInsight().get('is_approved')
      suggested:  @isSuggested()

    <article className = { insightClasses } >
      <Human 
        uuid            = { @getInsight().get('user_id') }
        showUnicornIcon = { true }
        type            = "user" />
      { @renderContent() }
      { @renderButtons() }
      { @renderSuggestion() }
    </article>
