# @cjsx React.DOM

ModalStack = require('components/modal_stack')

Carousel   = require('components/shared/carousel')


# Exports
#
module.exports = React.createClass

  displayName: 'TourApp'


  # Lifecycle methods
  #
  componentDidMount: ->
    ModalStack.show(
      <section className="tour">
        <Carousel>
          { @renderTourSlides() }
        </Carousel>
      </section>
    )


  # Renderers
  #
  renderTourSlides: ->
    [1..6].map (index) ->
      Slide = require("components/tour/slide_#{index}")

      <Slide key = { index } />

  render: ->
    null