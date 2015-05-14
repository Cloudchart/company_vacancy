# @cjsx React.DOM

GlobalState      = require('global_state/state')
UserStore        = require('stores/user_store.cursor')
PinStore         = require('stores/pin_store')
TrendingInsights = require('components/pinboards/pins/top')


# Exports
#
module.exports = React.createClass

  displayName: 'SuggestedInsights'

  mixins: [GlobalState.mixin]

  getDefaultProps: ->
    cursor:
      pins: PinStore.cursor.items
      user: UserStore.me()


  # Helpers
  #
  getUserPins: (user_id) ->
    PinStore.filterPinsForUser(user_id)


  # Renderers
  #
  render: ->
    return null unless (user = @props.cursor.user.deref(false))

    if @getUserPins(user.get('uuid')).size < 3
      <section className="suggested-insights cloud-columns cloud-columns-flex">
        <header>Trending Insights</header>
        <p>Collect successful founders' insights and put them to action: press the <i className="fa fa-thumb-tack"/> button to add an insight to your board.</p>
        <TrendingInsights filterPinned = { true } />
      </section>
    else
      <section className="suggested-insights cloud-columns cloud-columns-flex">
        <p>Explore unicorns' timelines to discover more insights on how they are growing.</p>
      </section>

