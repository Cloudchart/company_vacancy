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
    @updatePackery() if @props.dynamic


  startPackery: ->
    @packery = new Packery @getDOMNode(),
      transitionDuration: '0ms'
      isInitLayout: false


  updatePackery: ->
    clearTimeout @packery_timeout
    @packery_timeout = setTimeout =>
      @packery.reloadItems()
      @packery.layout()


  stopPackery: ->
    return unless @packery
    @packery.destroy()
    @packery = null


  # Lifecycle
  #

  componentDidMount: ->
    @startPackery() if @props.dynamic
    @mutationObserver = new MutationObserver(@observeMutation)
    @mutationObserver.observe(@getDOMNode(), { childList: true, subtree: true })


  componentDidUpdate: ->
    @updatePackery() if @props.dynamic


  componentWillUnmount: ->
    @stopPackery() if @props.dynamic
    @mutationObserver.disconnect()


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
