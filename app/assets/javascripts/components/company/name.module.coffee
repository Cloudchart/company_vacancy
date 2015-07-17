# @cjsx React.DOM


CompanyStore = require('stores/company')


# Main
#
Component = React.createClass

  # Component specifications
  #
  propTypes:
    uuid:  React.PropTypes.string.isRequired
    value: React.PropTypes.string
    url:   React.PropTypes.string

  getInitialState: ->
    @getStateFromStores()

  refreshStateFromStores: ->
    @setState(@getStateFromStores())

  getStateFromStores: ->
    company: CompanyStore.get(@props.uuid) || {}

  # Helpers
  #
  getName: ->
    @state.company.name || @props.value 

  getUrl: ->
    @state.company.company_url || @props.url


  # Lifecycle methods
  #
  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)


  render: ->
    if location.pathname != @getUrl()
      <a href={ @getUrl() } >
        { @getName() }
      </a>
    else
      <span>{ @getName() }</span>


# Exports
#
module.exports = Component
