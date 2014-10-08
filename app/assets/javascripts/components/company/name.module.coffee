# Imports
#
tag = React.DOM


CompanyStore = require('stores/company')


# Main
#
Component = React.createClass


  refreshStateFromStores: ->
    @setState(@getStateFromStores())

  
  getStateFromStores: ->
    company: CompanyStore.get(@props.key) || {}


  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)


  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)


  getInitialState: ->
    @getStateFromStores()


  render: ->
    (tag.span null, @state.company.name || @props.value)


# Exports
#
module.exports = Component
