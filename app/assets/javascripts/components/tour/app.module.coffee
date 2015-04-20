# @cjsx React.DOM

GlobalState  = require('global_state/state')
UserStore    = require('stores/user_store.cursor')

ModalStack   = require('components/modal_stack')

Carousel     = require('components/shared/carousel')


# Exports
#
module.exports = React.createClass

  displayName: 'TourApp'

  mixins: [GlobalState.mixin]

  getDefaultProps: ->
    cursor: UserStore.me()


  openTour: ->
    return null unless @props.cursor.deref(false)

    ModalStack.show(
      <section className="tour">
        <Carousel showNavButtons = { true } >
          { @renderTourSlides() }
        </Carousel>
      </section>
    )


  # Lifecycle methods
  #
  componentDidMount: ->
    @openTour()
    
  componentWillUpdate: ->
    @openTour()


  # Renderers
  #
  renderTourSlides: ->
    [1..6].map (index) =>
      Slide = require("components/tour/slide_#{index}")

      <Slide key = { index } user = { @props.cursor } />

  render: ->
    null