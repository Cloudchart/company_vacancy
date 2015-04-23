# @cjsx React.DOM

joinClasses = (firstClass, secondClass) ->
  (firstClass + " " + secondClass).trim()    


StandardButton = React.createClass
 
  propTypes:
    iconClass: React.PropTypes.string
    text:      React.PropTypes.string

  getDefaultProps: ->
    iconClass: ""
    text:      null

  render: ->
    children = []
    children.push @props.text if @props.text
    children.push <i key="icon" className="fa fa-fw #{@props.iconClass}"></i> if @props.iconClass.length > 0

    <button 
      className = { @props.className }
      disabled  = { @props.disabled }
      onClick   = { @props.onClick }
      type      = { @props.type }>
      <div>
        { children }
      </div>
    </button>


SyncButton = React.createClass
 
  propTypes:
    sync:              React.PropTypes.bool
    syncIconClass:     React.PropTypes.string

  getDefaultProps: ->
    sync:            false
    syncIconClass:   "fa-spinner"

  getInitialState: ->
    iconClass:   @props.iconClass
    sync:        @props.sync
    text:        @props.text


  updateWidth: ->
    @getDOMNode().style.width = getComputedStyle(@getDOMNode().childNodes[0]).width

  # Lifecycle methods
  #
  componentDidMount: ->
    @updateWidth()

  componentDidUpdate: ->
    @updateWidth()

  render: ->
    props = _.extend @props, className: joinClasses(@props.className, "sync")

    if @props.sync
      props = _.extend props,
                className: joinClasses(@props.className, "syncing sync")
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
  SyncButton:     SyncButton
  StandardButton: StandardButton
  CancelButton:   CancelButton
