##= require_self
##= require_tree ./blueprint


# Shortcuts
#
tag = React.DOM


# Modal container
#
ModalComponent = React.createClass

  componentDidMount: ->
    Arbiter.subscribe 'cc:blueprint:modal/show', @show
    Arbiter.subscribe 'cc:blueprint:modal/hide', @hide
  
  
  componentWillUnmount: ->
    Arbiter.unsubscribe 'cc:blueprint:modal/show', @show
    Arbiter.unsubscribe 'cc:blueprint:modal/hide', @hide


  getDefaultProps: ->
    modals: []

  getInitialState: ->
    content:    null
    is_visible: false
  
  
  show: (options = {}) ->
    @getDOMNode().style.display = 'block'

    Arbiter.publish 'cc:blueprint:identity-filter/show'

    React.unmountComponentAtNode(@refs['modal-container'].getDOMNode())
    @props.modals = [] unless options.keep_parent == true
    @props.modals.push(options.content)
    React.renderComponent(@props.modals[@props.modals.length - 1], @refs['modal-container'].getDOMNode())
  

  hide: (options = {}) ->
    @getDOMNode().style.display = 'none'

    Arbiter.publish 'cc:blueprint:identity-filter/hide'

    React.unmountComponentAtNode(@refs['modal-container'].getDOMNode())
    @props.modals.pop()
    
    @props.modals = [] if options.force == true

    @show({ content: @props.modals[@props.modals.length - 1] }) if @props.modals.length > 0
  
  
  onCloseButtonClick: (event) ->
    event.preventDefault()
    @hide()


  render: ->
    (tag.section {
      className: 'modal-overlay'
      style:
        display:  'none'
    },
      (tag.i {
        className:  'fa fa-times close'
        onClick:    @onCloseButtonClick
      })
      (tag.div { ref: 'modal-container', className: 'modal-container' },
        null
      )
    )


#
#
#


Blueprint = React.createClass

  render: ->
    (tag.article { className: 'chart' },
      @props.children
      (ModalComponent {})
    )


#
#
#

_.extend @cc.blueprint.react,
  Blueprint: Blueprint
