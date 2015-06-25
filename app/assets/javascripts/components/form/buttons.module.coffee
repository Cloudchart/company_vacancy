# @cjsx React.DOM

joinClasses = (firstClass, secondClass) ->
  (firstClass + " " + secondClass).trim()    

cx = React.addons.classSet
GlobalState = require('global_state/state')

AuthButton = React.createClass

  displayName: 'AuthButton'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      viewer: ->
        """
          Viewer {
            edges {
              is_authenticated
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('viewer'))

  getDefaultProps: ->
    cursor:
      viewer: require('stores/user_store.cursor').me()

  componentWillMount: ->
    @fetch()

  handleClick: ->
    event.preventDefault()
    event.stopPropagation()

    unless @props.cursor.viewer.get('is_authenticated')
      location.href = '/auth/twitter'
      return null

  render: ->
    component = React.Children.only(@props.children)

    props = if @props.cursor.viewer.get('is_authenticated')
      component.props
    else
      Object.assign(component.props, { onClick: @handleClick })

    React.addons.cloneWithProps(component, props)


CloseModalButton = React.createClass

  propTypes:
    shouldDisplay: React.PropTypes.bool

  getDefaultProps: ->
    shouldDisplay: true

  handleClick: (event) ->
    event.preventDefault()
    require('components/modal_stack').hide()

  render: ->
    return null unless @props.shouldDisplay

    <button className="close transparent" onClick={@handleClick}>
      <i className="fa cc-icon cc-times"></i>
    </button>


StandardButton = React.createClass
 
  propTypes:
    iconClass:    React.PropTypes.string
    text:         React.PropTypes.string
    wrapChildren: React.PropTypes.bool

  getDefaultProps: ->
    iconClass:    ""
    text:         null
    wrapChildren: false

  renderChildren: ->
    children = []
    children.push @props.text if @props.text
    children.push <i key="icon" className="fa fa-fw #{@props.iconClass}"></i> if @props.iconClass.length > 0

    if @props.wrapChildren then <div className="wrapper">{children}</div> else children

  render: ->
    <button 
      className = { @props.className }
      disabled  = { @props.disabled }
      onClick   = { @props.onClick }
      type      = { @props.type }>
      { @renderChildren() }
    </button>


SyncButton = React.createClass
 
  propTypes:
    sync:              React.PropTypes.bool
    syncDelay:         React.PropTypes.number
    syncIconClass:     React.PropTypes.string

  getDefaultProps: ->
    sync:            false
    syncDelay:       500
    syncIconClass:   "fa-spinner"

  getInitialState: ->
    iconClass:   @props.iconClass
    sync:        @props.sync
    text:        @props.text
    transition:  false


  # Helpers
  #
  updateWidth: ->
    @getDOMNode().style.width = getComputedStyle(@getDOMNode().childNodes[0]).width

  addTransition: ->
    @setState transition: true


  # Lifecycle methods
  #
  componentDidMount: ->
    @isAnimating = false
    @nextState   = {}

    @updateWidth()

    setTimeout =>
      @addTransition() if @isMounted()
    , 500

  componentWillReceiveProps: (nextProps) ->
    nextState = _.pick nextProps, ["iconClass", "sync", "text"]

    if @isAnimating
      @nextState = _.extend @nextState, nextState
    else
      @setState nextState

      if nextProps.sync && nextProps.sync != @props.sync
        @isAnimating = true

        setTimeout =>
          if @isMounted()
            @isAnimating = false
            @setState @nextState
        , @props.syncDelay

  componentDidUpdate: ->
    @updateWidth()


  render: ->
    props = _.extend @props, 
                    className:    joinClasses(@props.className, cx(sync: true, "no-transition": !@state.transition))
                    iconClass:    @state.iconClass
                    text:         @state.text
                    wrapChildren: true

    if @state.sync
      props = _.extend props,
                className: joinClasses(@props.className, "syncing")
                disabled:  true
                iconClass: joinClasses(@props.syncIconClass, "fa-spin")

    StandardButton(props)


CancelButton = React.createClass

  render: ->
    props = _.extend @props,
              iconClass:     "cc-icon cc-times"
              className:     "transparent cancel"

    SyncButton(props)

module.exports = 
  SyncButton:       SyncButton
  StandardButton:   StandardButton
  CancelButton:     CancelButton
  CloseModalButton: CloseModalButton
  AuthButton:       AuthButton
