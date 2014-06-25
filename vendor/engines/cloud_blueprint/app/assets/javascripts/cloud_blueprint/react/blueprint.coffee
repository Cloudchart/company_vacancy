##= require_self
##= require_tree ./blueprint


# Shortcuts
#
tag = React.DOM


# Modal Title Component
#
ModalTitleComponent = React.createClass

  onClick: (event) ->
    event.preventDefault()
    cc.blueprint.react.modal.close()


  render: ->
    (tag.header {},
      (tag.a {
        href: '#',
        onClick: @onClick
      },
        (tag.i { className: 'fa fa-angle-left' })
      )
      @props.title
    )


# Modal container
#
ModalComponent = React.createClass

  componentDidMount: ->
    Arbiter.subscribe 'cc:blueprint:modal/show', @show
    Arbiter.subscribe 'cc:blueprint:modal/hide', @hide
  
  
  componentWillUnmount: ->
    Arbiter.unsubscribe 'cc:blueprint:modal/show', @show
    Arbiter.unsubscribe 'cc:blueprint:modal/hide', @hide
  

  componentDidUpdate: ->
    # Show or hide identity filter
    Arbiter.publish "cc:blueprint:identity-filter/#{if @state.is_visible then 'show' else 'hide'}"
    
    # Unmount previous modal component
    React.unmountComponentAtNode(@refs.container.getDOMNode())
    
    # Render current modal component if it exists
    React.renderComponent(@state.modal_component, @refs.container.getDOMNode()) if @state.modal_component
  
  
  getDefaultProps: ->
    title:  'Back'
    modals: []
  
  
  getInitialState: ->
    is_visible:       false
    modal_component:  null
  
  
  toggle: ->
    currOptions = @props.modals[@props.modals.length - 1]
    prevOptions = @props.modals[@props.modals.length - 2]

    @setState
      title:            if currOptions then currOptions.title else @props.title
      is_visible:       if currOptions then true else false
      modal_component:  if currOptions then currOptions.content else null


  show: (options = {}) ->
    # Fetch previous options
    prevOptions = @props.modals[@props.modals.length - 1]
    
    # Remove previous options if its key is the same as new
    @props.modals.pop() if prevOptions and prevOptions.key == options.key
    
    # Add current options
    @props.modals.push(options)
    
    # Show or hide modal component
    @toggle()
  

  hide: (options = {}) ->
    # Remove last options
    @props.modals.pop()
    
    # Clean options stack if forced
    @props.modals = [] if options.force == true

    # Show or hide modal component
    @toggle()
  
  
  onCloseButtonClick: (event) ->
    event.preventDefault()
    @hide()


  render: ->
    (tag.section {
      className: 'modal-overlay'
      style:
        visibility:  if @state.is_visible then 'visible' else 'hidden'
    },
      (ModalTitleComponent { title: @state.title || @props.title })
      (tag.div { ref: 'container', className: 'modal-container' })
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
