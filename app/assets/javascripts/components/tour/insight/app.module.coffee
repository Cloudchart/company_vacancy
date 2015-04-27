# @cjsx React.DOM
UserStore         = require('stores/user_store.cursor')

TourIntroduction  = require('components/tour/insight/introduction')
TourLesson        = require('components/tour/insight/lesson')
TourList          = require('components/tour/insight/list')

NavigatorMixin    = require('components/mixins/navigator')

# Exports
#
module.exports = React.createClass

  displayName: 'InsightTourApp'

  mixins: [NavigatorMixin]


  # Helpers
  #
  getPositionsNumber: ->
    3

  getSlideClass: (indexes...) ->
    cx(
      active:            indexes.indexOf(@state.position) != -1
      slide:             true
      "with-transition": @state.isNexted
    )


  # Handlers
  #
  handleNavigationButtons: (event) ->
    @goToPrev() if event.keyCode == 37
    @goToNext() if event.keyCode == 39


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor = UserStore.me()

  componentDidMount: ->
    window.addEventListener('keydown', @handleNavigationButtons)

  componentWillUnmount: ->
    window.removeEventListener('keydown', @handleNavigationButtons)


  # Renderers
  #
  render: ->
    <section className="tour navigator">
      <section className="tour-wrapper">
        <TourIntroduction className = { @getSlideClass(0) } />
        <TourLesson       className = { @getSlideClass(1) } />
        <TourList         className = { @getSlideClass(2) } user = { @cursor } />
      </section>
      { @renderPrevButton() }
      { @renderNextButton() }
      { @renderNavigation() }
    </section>
