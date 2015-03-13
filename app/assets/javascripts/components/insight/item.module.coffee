# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinStore    = require('stores/pin_store')
UserStore   = require('stores/user_store.cursor')


# Components
#
Avatar        = require('components/avatar')
PinButton     = require('components/pinnable/pin_button')
EditPinButton = require('components/pinnable/edit_pin_button')


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


  # Renderers
  #
  renderContent: ->
    <section className="content">
      { @props.cursor.pin.get('content') }
    </section>

  renderUser: ->
    <section className="user">
      <Avatar
        avatarURL       = { @state.user.get('avatar_url') }
        backgroundColor = "transparent"
        value           = { @state.user.get('full_name') }
      />
      <section>
        <p className="name">
          { @state.user.get('full_name') }
        </p>
        <p className="occupation">
          { @state.user.get('occupation') }
        </p>
      </section>
    </section>

  renderButtons: ->
    <ul className="round-buttons">
      <EditPinButton uuid={ @props.uuid } />
      <PinButton {...@gatherAttributes()} title={ @props.cursor.pin.get('content') } />
    </ul>


  render: ->
    return null unless @props.cursor.pin.deref()
    return null unless @state.user.deref()

    <li className="insight">
      { @renderUser() }
      { @renderContent() }
      { @renderButtons() }
    </li>
