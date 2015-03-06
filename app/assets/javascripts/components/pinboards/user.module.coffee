# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
UserStore = require('stores/user_store.cursor')


# Components
#
Avatar = require('components/avatar')


# Exports
#
module.exports = React.createClass

  displayName: 'PinUser'


  componentWillMount: ->
    @cursor = UserStore.cursor.items.cursor(@props.uuid)


  renderAvatar: ->
    <aside>
      <Avatar
        avatarURL       = { @cursor.get('avatar_url') }
        backgroundColor = "transparent"
        value           = { @cursor.get('full_name') }
      />
    </aside>


  renderCredentials: ->
    <section>
      <p className="name">{ @cursor.get('full_name') }</p>
      <p className="occupation">{ @cursor.get('occupation') }</p>
    </section>


  render: ->
    return null unless @cursor.deref(false)

    <div className="user">
      { @renderAvatar() }
      { @renderCredentials() }
    </div>
