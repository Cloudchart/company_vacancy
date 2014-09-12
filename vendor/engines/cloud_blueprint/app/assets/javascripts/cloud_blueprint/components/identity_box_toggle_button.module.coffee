# Imports
#
tag = React.DOM


IdentityBoxActions = require('cloud_blueprint/actions/identity_box_actions')


# Main
#
Component = React.createClass


  onClick: ->
    IdentityBoxActions.toggle(@state.isActive)


  getDefaultProps: ->
    settings:
      isIdentityBoxVisible: false
  
  
  componentWillReceiveProps: (nextProps) ->
    @setState({ isActive: !!nextProps.settings.isIdentityBoxVisible }) if nextProps.settings


  getInitialState: ->
    isActive: !!@props.settings.isIdentityBoxVisible


  render: ->
    icon = if @state.isActive then "compress" else "expand"
    
    (tag.button {
      type:     'button'
      onClick:  @onClick
      style:
        position: 'absolute'
        left:     10
        bottom:   10
    },
      (tag.i { className: "fa fa-#{icon}" })
    )


# Exports
#
module.exports = Component
