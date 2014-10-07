# Imports
#
tag = React.DOM


# Actions
#


# Stores
#
CompanyStore = require('stores/company')


# Components
#
SlugComponent = require('components/company/settings/slug')



# Main
#
Component = React.createClass


  refreshStateFromStores: ->
    @setState(@getStateFromStores())


  getStateFromStores: ->
    company: CompanyStore.get(@props.key)
  
  
  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)


  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)


  getInitialState: ->
    @getStateFromStores()


  render: ->
    (tag.article {
      className: 'company-settings'
    },
      
      # Slug Component
      #
      SlugComponent({
        company:  @state.company
        url:      @props.url
        sync:     CompanyStore.getSync(@props.key)
        errors:   CompanyStore.errorsFor(@props.key)
      })
      
      
    )


# Exports
#
module.exports = Component
