# @cjsx React.DOM

GlobalState       = require('global_state/state')


CompanyStore      = require('stores/company_store.cursor')
UserStore         = require('stores/user_store.cursor')


CompanyList       = require('components/company/list')


UserCompanies = React.createClass

  displayName: 'CompanyList'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:

    companiesCount: (user_id) ->
      UserStore.cursor.items.getIn([user_id, 'related_companies'], Immutable.Seq()).size


    queries:

      user: ->
        """
          User {
            edges {
              related_companies,
              favorite_companies
            }
          }
        """

      companies: ->
        """
          User {
            related_companies {
              #{CompanyList.ItemQuery}
            },
            favorite_companies {
              #{CompanyList.ItemQuery}
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('user'), id: @props.user_id).then @fetchCompanies


  fetchCompanies: ->
    GlobalState.fetch(@getQuery('companies'), id: @props.user_id).then =>
      @setState
        fetched: true


  # Helpers
  #
  relatedCompaniesIds: ->
    @cursor.user.get('related_companies', Immutable.Seq())
      .sortBy (i) -> i.get('name')
      .map (i) -> i.get('id')
      .valueSeq()


  fevoriteCompaniesIds: ->
    @cursor.user.get('favorite_companies', Immutable.Seq())
      .sortBy (i) -> i.get('name')
      .map (i) -> i.get('id')
      .valueSeq()


  relatedCompanies: ->
    @relatedCompaniesIds()
      .map (i) -> CompanyStore.get(i)
      .toArray()


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      user:       UserStore.cursor.items.cursor(@props.user_id)
      companies:  CompanyStore.cursor.items

    @fetch()


  getInitialState: ->
    fetched: false


  # Renderers
  #

  renderPlaceholder: (_, i) ->
    <section key={ i } className="cloud-column">
      <section className="company-preview cloud-card placeholder" />
    </section>


  renderPlaceholders: ->
    placeholders = Immutable.Repeat('dummy', @relatedCompaniesIds().size || 2).map @renderPlaceholder

    <section className="companies-list cloud-columns cloud-columns-flex">
      { placeholders.toArray() }
    </section>


  render: ->
    return @renderPlaceholders() unless @state.fetched

    <CompanyList companies = { @relatedCompanies() } />


module.exports = UserCompanies
