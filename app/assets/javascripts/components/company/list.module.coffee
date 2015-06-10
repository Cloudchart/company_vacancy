# @cjsx React.DOM

GlobalState = require('global_state/state')

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


  mixins: [GlobalState.query.mixin]


  statics:
    ItemQuery: ItemQuery

    queries:
      companies: ->
        """
          Viewer {
            companies_through_roles {
              #{ItemQuery}
            },
            favorite_companies {
              #{ItemQuery}
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
