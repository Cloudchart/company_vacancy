# @cjsx React.DOM

GlobalState       = require('global_state/state')

CompanyStore      = require('stores/company_store.cursor')
UserStore         = require('stores/user_store.cursor')

CompanyPreview    = require('components/company/preview')
Subscription      = require('components/shared/subscription')


EmptyCompanies    = Immutable.fromJS([{ id: 'dummy-1', name: '' }, { id: 'dummy-2', name: '' }])


module.exports = React.createClass

  displayName: 'CompaniesApp'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:
      viewer: ->
        """
          Viewer {
            published_companies {
              #{CompanyPreview.getQuery('company')}
            },
            related_companies {
              #{CompanyPreview.getQuery('company')}
            },
            edges {
              published_companies,
              related_companies,
              is_editor
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('viewer'))


  # Lifecycle methods
  #

  componentWillMount: ->
    @fetch()


  getDefaultProps: ->
    cursor:
      companies: CompanyStore.cursor.items
      user:      UserStore.me()


  # Renderers
  #

  renderAddButton: ->
    return null unless @props.cursor.user.get('is_editor', false)

    <div className="company-add button green">
      <a href="companies/new">
        <i className="fa fa-plus"></i>
        Create company
      </a>
    </div>


  renderHeader: ->
    return null unless @props.cursor.user.get('is_editor', false)

    <header className="cloud-columns cloud-columns-flex">
      { @renderAddButton() }
    </header>


  renderCompany: (placeholder) ->
    company = CompanyStore.get(placeholder.get('id'))

    if company
      <section key={ placeholder.get('id') } className="cloud-column">
        <CompanyPreview uuid={ company.get('uuid') } />
      </section>
    else
      <section key={ placeholder.get('id') } className="cloud-column">
        <section className="company-preview cloud-card placeholder" />
      </section>


  renderCompanies: ->
    @props.cursor.user
      .get('published_companies', EmptyCompanies)
      .concat(@props.cursor.user.get('related_companies', EmptyCompanies))
      .toSet()
      .sortBy (i) -> i.get('name')
      .map    @renderCompany


  renderSubscription: ->
    <Subscription
      asBlock   = { true }
      text      = "We're adding new companies every week — join our mailing list to get updates on new unicorns' timelines and useful insights." />


  renderFooter: ->
    @renderSubscription()


  render: ->
    <section className="cloud-profile-companies">
      { @renderHeader() }
      <section className="companies-list cloud-columns cloud-columns-flex">
        { @renderCompanies().toArray() }
      </section>
      { @renderFooter() }
    </section>
