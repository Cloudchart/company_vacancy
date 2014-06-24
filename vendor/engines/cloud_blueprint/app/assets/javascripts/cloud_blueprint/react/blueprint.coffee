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
    # Show modal container
    @getDOMNode().style.display = 'block'

    Arbiter.publish 'cc:blueprint:identity-filter/show'
    
    # Unmount previous form
    React.unmountComponentAtNode(@refs['modal-container'].getDOMNode())
    
    # Get previous options
    previous_options = @props.modals[@props.modals.length - 1]

    # Remove previous options from stack if it has same key as current options
    @props.modals.pop() if previous_options and previous_options.key == options.key

    # Add current options to stack
    @props.modals.push(options)

    # Mount current form
    React.renderComponent(@props.modals[@props.modals.length - 1].content, @refs['modal-container'].getDOMNode())
  

  hide: (options = {}) ->
    # Hide modal container
    @getDOMNode().style.display = 'none'

    Arbiter.publish 'cc:blueprint:identity-filter/hide'

    # Unmount current form
    React.unmountComponentAtNode(@refs['modal-container'].getDOMNode())
    
    # Remove current options
    @props.modals.pop()
    
    # Cleanup options stack if forced to close
    @props.modals = [] if options.force == true

    # Show latest form if it is available
    @show(@props.modals.pop()) if @props.modals.length > 0
  
  
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
