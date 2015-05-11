# @cjsx React.DOM

CompanyPreview   = require('components/company/preview')


CompanyList = React.createClass

  displayName: 'CompanyList'


  # Component specifications
  #
  propTypes:
    companies:      React.PropTypes.array.isRequired


  # Helpers
  #
  isLoaded: ->
    @cursor.companies.deref(false)


  # Renderers
  #
  renderCompanies: ->
    @props.companies.map (company, index) =>
      <section key={index} className="cloud-column">
        <CompanyPreview 
          key        = { index }
          uuid       = { company.get('uuid') } />
      </section>


  render: ->
    <section className="companies-list cloud-columns cloud-columns-flex">
      { @renderCompanies() }
    </section>


module.exports = CompanyList