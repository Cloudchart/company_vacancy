# @cjsx React.DOM

GlobalState   = require('global_state/state')

# Stores
#
UserStore     = require('stores/user_store.cursor')
CompanyStore  = require('stores/company_store.cursor')


# Components
#
Company       = require('components/cards/company')


# Component
#
module.exports = React.createClass


  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      companies: ->
        """
          User {
            companies_through_roles {
              #{Company.getQuery('company')}
            },
            edges {
              companies_through_roles
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('companies'), { id: @props.user })


  # Lifecycle
  #

  componentWillMount: ->
    @cursor =
      user:       UserStore.cursor.items.cursor(@props.user)
      companies:  CompanyStore.cursor.items


  componentDidMount: ->
    @fetch()


  # Render
  #
  renderCompany: (id) ->
    <Company key={ id } company={ id } />


  renderCompanies: ->
    @cursor.user.get('companies_through_roles', Immutable.Seq())
      .sortBy   (item) -> item.get('name')
      .map      (item) -> item.get('id')
      .map      @renderCompany
      .toArray()


  render: ->
    <section className="companies-list cloud-columns cloud-columns-flex">
      { @renderCompanies() }
    </section>
