# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#

CompanyStore = require('stores/company_store.cursor')


# Constants
#
DescriptionMaxLength = 170


# Utils
#

pluralize = require('utils/pluralize')

stripDescription = (description) ->
  return null unless description
  description = description.replace(/(<([^>]+)>)/ig, " ").trim()
  description = description.slice(0, DescriptionMaxLength - 3) + '...' if description.length > DescriptionMaxLength
  description


# Component 
#
module.exports = React.createClass

  mixins: [GlobalState.query.mixin]


  statics:
    queries:
      company: ->
        """
          Company {
            edges {
              posts_count,
              insights_count,
              is_followed,
              is_invited
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('company'), { id: @props.company })


  # Render
  #

  renderHeader: (company) ->
    <header>
      <h1>{ company.name }</h1>
    </header>


  renderInsightsCount: (company) ->
    return null unless company.insights_count
    <li>{ pluralize(company.insights_count, 'insight', 'insights') }</li>


  renderPostsCount: (company) ->
    return null unless company.pins_count
    <li>{ pluralize(company.posts_count, 'post', 'posts') }</li>


  renderStats: (company) ->
    <ul className="stats">
      { @renderInsightsCount(company) }
      { @renderPostsCount(company) }
    </ul>


  renderInviteLabel: (company) ->
    return null unless company.is_invited
    <li className="label">Invited</li>


  renderFollowButton: (company) ->
    return null if company.is_followed
    <li><button className="cc">Follow</button></li>


  renderFollowLabel: (company) ->
    return null unless company.is_followed
    <li className="label">Following</li>


  renderActions: (company) ->
    <ul className="actions">
      { @renderInviteLabel(company) }
      { @renderFollowLabel(company) }
      { @renderFollowButton(company) }
    </ul>


  renderInfo: (company) ->
    <div className="info">
      { @renderStats(company) }
      { @renderActions(company) }
    </div>


  renderDescription: (company) ->
    return null unless description = stripDescription(company.description)

    <p className="description">{ description }</p>


  renderFooter: (company) ->
    <footer>

    </footer>


  renderCompany: ->
    company = CompanyStore.get(@props.company).toJS()

    <article className="cloud-card company-preview">
      { @renderHeader(company) }
      { @renderInfo(company) }
      { @renderDescription(company) }
      { @renderFooter(company) }
    </article>


  renderPlaceholder: ->
    <section className="company-preview cloud-card placeholder" />


  renderCompanyOrPlaceholder: ->
    if CompanyStore.has(@props.company)
      @renderCompany()
    else
      @renderPlaceholder()


  render: ->
    <section className="cloud-column">
      { @renderCompanyOrPlaceholder() }
    </section>
