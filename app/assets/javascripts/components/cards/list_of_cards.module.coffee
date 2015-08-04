# @cjsx React.DOM

# Exports
#
module.exports = React.createClass

  displayName: 'ListOfCards'

  # Specification
  #

  propTypes:
    dynamic:  React.PropTypes.bool


  getDefaultProps: ->
    dynamic: true


  # Packery
  #

  startPackery: ->
    setTimeout =>
      @packery = new Packery @getDOMNode(),
        transitionDuration: '0ms'
    , 10


  updatePackery: ->
    clearTimeout @packery_timeout
    @packery_timeout = setTimeout =>
      @packery.reloadItems()
      @packery.layout()
    , 10


  stopPackery: ->
    return unless @packery
    @packery.destroy()
    @packery = null


  # Lifecycle
  #

  componentDidMount: ->
    @startPackery() if @props.dynamic


  componentDidUpdate: ->
    @updatePackery() if @props.dynamic


  componentWillUnmount: ->
    @stopPackery() if @props.dynamic


  # Render child
  #
  renderChild: (item) ->
    <div className="item">
      { React.addons.cloneWithProps(item, { onUpdate: @updatePackery }) }
    </div>


  # Render children
  #
  renderChildren: ->
    React.Children.map(@props.children, @renderChild)


  # Main Render
  #
  render: ->
    <section className="flow">
      { @renderChildren() }
    </section>
