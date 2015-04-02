# @cjsx React.DOM

GlobalState    = require('global_state/state')
UserStore      = require('stores/user_store.cursor')   
PinsComponent  = require('components/pinboards/pins')


# Exports
#
module.exports = React.createClass

  displayName: 'PinboardsApp'

  mixins: [GlobalState.mixin]

  componentWillMount: ->
    @cursor = UserStore.me()

  render: ->
    return null unless @cursor.deref(false)

    <PinsComponent user_id={ @cursor.get('uuid') } />
