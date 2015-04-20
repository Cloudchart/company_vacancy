# @cjsx React.DOM

ModalStack = require('components/modal_stack')

Carousel   = require('components/shared/carousel')

Slide1     = require('components/tour/slide_1')


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
    [1, 2, 3, 4, 5, 6].map (index) ->
      <Slide1 key = { index } />

  render: ->
    null