# @cjsx React.DOM

joinClasses = (firstClass, secondClass) ->
  (firstClass + " " + secondClass).trim()

BaseButton = React.createClass

  propTypes:
    className:    React.PropTypes.string
    disabled:     React.PropTypes.bool
    defaultClass: React.PropTypes.string
    type:         React.PropTypes.string

    onClick:   React.PropTypes.func

  getDefaultProps: ->
    className:    ""
    disabled:     false
    type:         "button"
    children:     null
    defaultClass: ""

    onClick:   ->

  render: ->
    className = joinClasses(@props.className, @props.defaultClass)

    <button type      = @props.type
            disabled  = @props.disabled
            className = className
            onClick   = {@props.onClick}>
      { @props.children }
    </button>


# TODO rewrite when added new props syntax from React 0.12
StandardButton = React.createClass
 
  propTypes:
    text:      React.PropTypes.string
    iconClass: React.PropTypes.string

  getDefaultProps: ->
    text:      null
    iconClass: ""

  render: ->
    children = []
    if @props.text
      children.push @props.text
    if @props.iconClass.length > 0
      children.push <i key="icon" className="fa fa-fw #{@props.iconClass}"></i>

    BaseButton(_.omit(@props, ["children", "text", "iconClass"]), 
      children
    )

SyncButton = React.createClass
 
  propTypes:
    sync:           React.PropTypes.bool
    syncText:       React.PropTypes.string
    syncClassName:  React.PropTypes.string
    syncIconClass:  React.PropTypes.string

  getDefaultProps: ->
    sync:           false
    syncText:       null
    syncClassName:  null
    syncIconClass:  "fa-spinner"

  render: ->
    props = _.omit(@props, ["sync", "syncText", "syncClass", "syncIcon"])

    if @props.sync
      props = _.extend props,
                disabled:  true
                text:      if _.isNull(@props.syncText) then @props.text else @props.syncText
                className: if _.isNull(@props.syncClassName) then @props.className else @props.syncClassName
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