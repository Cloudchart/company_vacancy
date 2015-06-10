# @cjsx React.DOM

GlobalState        = require('global_state/state')

UserStore          = require('stores/user_store.cursor')
PinboardStore      = require('stores/pinboard_store')

ImportantPinboards = require('components/pinboards/lists/important')


# Exports
#
module.exports = React.createClass

  displayName: 'SuggestedInsights'

  mixins: [GlobalState.mixin]

  getDefaultProps: ->
    cursor:
      pinboards: PinboardStore.cursor.items
      user:      UserStore.me()


  # Helpers
  #
  getUserPinboards: (user_id) ->
    PinboardStore.filterUserPinboards(user_id)


  # Renderers
  #
  render: ->
    return null unless (user = @props.cursor.user.deref(false))

    if @getUserPinboards(user.get('uuid')).size < 3
      <ImportantPinboards
        header      = "Featured Collections"
        description = "Follow our most popular collections to start, or, create your own."
        filterSaved = { true } />
    else
      null
