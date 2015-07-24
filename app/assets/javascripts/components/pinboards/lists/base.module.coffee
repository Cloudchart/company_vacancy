# @cjsx React.DOM

# Exports
#
module.exports = React.createClass


  # Utils
  #

  startPackery: ->
    @packery = new Packery @getDOMNode(),
      transitionDuration: '0s'
      itemSelector: '.packery-item'


  updatePackery: ->
    clearTimeout @packeryTimeout
    @packeryTimeout = setTimeout =>
      @packery.reloadItems()
      @packery.layout()
    , 100


  stopPackery: ->
    @packery.destroy()


  # Event handlers
  #

  onUpdate: ->
    @updatePackery()


  # Lifecycle
  #

  componentDidMount: ->
    @startPackery()


  componentDidUpdate: ->
    @updatePackery()


  componentWillUnmount: ->
    @stopPackery()


  # Render
  #

  renderChildren: ->
    React.Children.map @props.children, (child) =>
      <section className="cloud-column packery-item" key={ child.props.key }>
        { React.addons.cloneWithProps(child, { onUpdate: @onUpdate }) }
      </section>


  # Main Render
  #

  render: ->
    <section className="cloud-columns cloud-columns-flex">
      { @renderChildren() }
    </section>
