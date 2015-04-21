# @cjsx React.DOM

UserStore         = require('stores/user_store.cursor')

TourIntroduction  = require('components/tour/introduction')
TourCompanies     = require('components/tour/companies')
TourTimeline      = require('components/tour/timeline')
TourSubscription  = require('components/tour/subscription')

NavigatorMixin    = require('components/mixins/navigator')

# Exports
#
module.exports = React.createClass

  displayName: 'TourApp'

  mixins: [NavigatorMixin]

  getPositionsNumber: ->
    5


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor = UserStore.me()


  # Renderers
  #
  renderIntroduction: ->
    return null unless @state.position == 0

    <TourIntroduction onNext = { @goToNext } user = { @cursor } />

  renderCompanies: ->
    return null unless @state.position == 1

    <TourCompanies />

  renderTimeline: ->
    return null unless @state.position == 2 || @state.position == 3

    <TourTimeline />

  renderSubscription: ->
    return null unless @state.position == 4

    <TourSubscription user = { @cursor } />


  render: ->
    <section className="tour navigator">
      { @renderIntroduction() }
      { @renderCompanies() }
      { @renderTimeline() }
      { @renderSubscription() }
      { @renderPrevButton() }
      { @renderNextButton() }
      { @renderNavigation() }
    </section>