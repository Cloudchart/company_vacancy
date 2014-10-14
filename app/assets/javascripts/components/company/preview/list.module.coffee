###
  Used in:
  cloud_profile/controllers/main
###

tag = React.DOM

CompanyStore = require('stores/company')
CompanyPreviewItem = require('components/company/preview/item')

MainComponent = React.createClass

  refreshStateFromStore: ->
    @setState(@getStateFromStores())

  getStateFromStores: ->
    companies: CompanyStore.all()

  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)

  getInitialState: ->
    @getStateFromStores()

  render: ->
    companies = _.map(@state.companies, (company) ->
      CompanyPreviewItem {
        company: company
        key: company.uuid
      }
    )

    tag.section { className: "company-previews" },
      companies

module.exports = MainComponent
