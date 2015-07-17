# @cjsx React.DOM

CompanyStore = require('stores/company_store.cursor')


# Components
#
CompanyPreview   = require('components/company/preview')


# Constants
#
ItemQuery = CompanyPreview.getQuery('company')


# Component
#
CompanyList = React.createClass

  displayName: 'CompanyList'


  statics:
    ItemQuery: ItemQuery


  propTypes:
    companies: React.PropTypes.array.isRequired


  # Renderers
  #
  renderCompanies: ->
    @props.companies.map (company, index) =>
      <section key={index} className="cloud-column">
        <CompanyPreview uuid = { company.get('uuid') } />
      </section>


  render: ->
    <section className="companies-list cloud-columns cloud-columns-flex">
      { @renderCompanies() }
    </section>


module.exports = CompanyList
