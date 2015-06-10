# @cjsx React.DOM

GlobalState = require('global_state/state')

CompanyPreview   = require('components/company/preview')


CompanyList = React.createClass

  displayName: 'CompanyList'


  mixins: [GlobalState.query.mixin]


  statics:
    queries:
      companies: ->
        """
          Viewer {
            companies_through_roles {
              #{CompanyPreview.getQuery('company')}
            },
            favorite_companies {
              #{CompanyPreview.getQuery('company')}
            }
          }
        """


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
