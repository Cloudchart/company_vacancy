# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinStore    = require('stores/pin_store')
UserStore   = require('stores/user_store.cursor')


# Components
#
Avatar      = require('components/avatar')
PinButton   = require('components/pinnable/pin_button')


# Utils
#
cx = React.addons.classSet


# Exports
#
module.exports = React.createClass

  displayName: 'InsiteItem'

  mixins: [GlobalState.mixin]

  statics:
    getCursor: (id) ->
      pin:    PinStore.cursor.items.cursor(id)
      users:  UserStore.cursor.items


  gatherAttributes: ->
    parent_id:      @props.cursor.pin.get('uuid')
    pinnable_id:    @props.cursor.pin.get('pinnable_id')
    pinnable_type:  @props.cursor.pin.get('pinnable_type')


  getStateFromStores: ->
    user:         @props.cursor.users.cursor(@props.cursor.pin.get('user_id'))


  onGlobalStateChange: ->
    @setState @getStateFromStores()


  getInitialState: ->
    @getStateFromStores()


  renderAvatar: ->
    <aside>
      <Avatar
        avatarURL       = { @state.user.get('avatar_url') }
        backgroundColor = "transparent"
        value           = { @state.user.get('full_name') }
      />
    </aside>


  renderUser: ->
    <section>
      <p className="name">
        { @state.user.get('full_name') }
      </p>
      <p className="occupation">
        { @state.user.get('occupation') }
      </p>
      <p className="comment">
        { @props.cursor.pin.get('content') }
      </p>
    </section>


  renderButtons: ->
    <ul className="round-buttons">
      <PinButton {...@gatherAttributes()} title={ @props.cursor.pin.get('content') } />
    </ul>


  render: ->
    return null unless @props.cursor.pin.deref()
    return null unless @state.user.deref()

    <li className="insite">
      { @renderAvatar() }
      { @renderUser() }
      { @renderButtons() }
    </li>
