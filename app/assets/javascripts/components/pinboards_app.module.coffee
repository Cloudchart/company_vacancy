# @cjsx React.DOM

GlobalState       = require('global_state/state')
UserStore         = require('stores/user_store.cursor')
PinStore          = require('stores/pin_store')
UserPins          = require('components/pinboards/pins/user')
SuggestedInsights = require('components/pinboards/pins/suggested')


# Exports
#
module.exports = React.createClass

  displayName: 'PinboardsApp'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    user_id: React.PropTypes.string.isRequired

  getInitialState: ->
    isLoaded: false


  # Helpers
  #
  fetch: ->
    GlobalState.fetch(UserPins.getQuery('pins'), id: @props.user_id)

  isLoaded: ->
    @state.isLoaded

  getUserPins: ->
    PinStore.filterPinsForUser(@props.user_id)


  # Lifecycle methods
  #
  componentWillMount: ->
    @fetch().then(=> @setState isLoaded: true) unless @isLoaded()


  # Renderers
  #
  renderSuggestedInsights: ->
    return null if @getUserPins().size >= 3

    <SuggestedInsights />

  render: ->
    if @isLoaded()
      <section className="pinboards-wrapper">
        <UserPins user_id={ @props.user_id } />
        { @renderSuggestedInsights() }
      </section>
    else
      <section className="pinboards-wrapper">
        <section className="pins cloud-columns cloud-columns-flex">
          <section className="cloud-column">
            <section className="pin cloud-card placeholder" />
          </section>
          <section className="cloud-column">
            <section className="pin cloud-card placeholder" />
          </section>
        </section>
      </section>
