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
    uuid:           @props.cursor.pin.get('uuid')
    parent_id:      @props.cursor.pin.get('parent_id')
    pinnable_id:    @props.cursor.pin.get('pinnable_id')
    pinnable_type:  @props.cursor.pin.get('pinnable_type')

  getStateFromStores: ->
    user: @props.cursor.users.cursor(@props.cursor.pin.get('user_id'))

  onGlobalStateChange: ->
    @setState @getStateFromStores()

  getInitialState: ->
    @getStateFromStores()


  # Helpers
  #
  isLink: (string) ->
    /^https?:\/\/.*/.test(string)


  # Renderers
  #
  renderOriginIcon: ->
    <i className="fa fa-code" />

  renderOrigin: ->
    return null unless (origin = @props.cursor.pin.get('origin'))

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
      { @props.cursor.pin.get('content') }
      { " " }
      { @renderOrigin() }
    </section>

  renderButtons: ->
    <ul className="round-buttons">
      <ApprovePinButton uuid = { @props.uuid } />
      <EditPinButton uuid={ @props.uuid } />
      <PinButton {...@gatherAttributes()} title={ @props.cursor.pin.get('content') } />
    </ul>


  render: ->
    return null unless @props.cursor.pin.deref()
    return null unless @state.user.deref()

    insightClasses = cx
      insight: true
      item: true
      unapproved: !@props.cursor.pin.get('is_approved')

    <article className = { insightClasses } >
      <Human 
        uuid            = { @props.cursor.pin.get('user_id') }
        showUnicornIcon = { true }
        type            = "user" />
      { @renderContent() }
      { @renderButtons() }
    </article>
