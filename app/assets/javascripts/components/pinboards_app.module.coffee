# @cjsx React.DOM

GlobalState    = require('global_state/state')
UserStore      = require('stores/user_store.cursor')   
UserPins       = require('components/pinboards/pins/user')


# Exports
#
module.exports = React.createClass

  displayName: 'PinboardsApp'

  mixins: [GlobalState.mixin]

  componentWillMount: ->
    @cursor = UserStore.me()

  render: ->
    return null unless @cursor.deref(false)

    <UserPins user_id={ @cursor.get('uuid') } showPlaceholders = { true } />
