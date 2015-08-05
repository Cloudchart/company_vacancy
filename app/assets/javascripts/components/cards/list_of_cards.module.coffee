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

  observeMutation: ->
    @handlePackery()


  handlePackery: ->
    return unless @props.dynamic

    clearTimeout @packeryTimeout
    @packeryTimeout = setTimeout =>
      if @packery then @updatePackery() else @startPackery()
    # , 250


  startPackery: ->
    @packery = new Packery @getDOMNode(),
      transitionDuration: '0ms'


  updatePackery: ->
    @packery.reloadItems() if @shouldReloadPackeryItems
    @packery.layout()
    @shouldReloadPackeryItems = false


  stopPackery: ->
    @packery.destroy() if @packery


  # Lifecycle
  #

  componentDidMount: ->
    @handlePackery()
    @mutationObserver = new MutationObserver(@observeMutation)
    @mutationObserver.observe(@getDOMNode(), { childList: true, subtree: true })


  componentDidUpdate: ->
    @handlePackery() if @props.dynamic


  componentWillUnmount: ->
    @stopPackery()
    @mutationObserver.disconnect()


  componentWillReceiveProps: (nextProps) ->
    if React.Children.count(nextProps.children) isnt React.Children.count(@props.children)
      @shouldReloadPackeryItems = true


  # Render child
  #
  renderChild: (item) ->
    <div className="item">
      { item }
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
