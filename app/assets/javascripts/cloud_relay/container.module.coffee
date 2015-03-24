module.exports = (component, descriptor) ->

  container = React.createClass

    displayName: component.displayName + 'CloudRelayContainer'

    render: ->
      React.createElement(component, @props)
