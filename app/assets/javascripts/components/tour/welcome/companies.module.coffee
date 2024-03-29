# @cjsx React.DOM

GlobalState    = require('global_state/state')

CompanyPreview = require('components/company/preview')

CompanyStore   = require('stores/company_store.cursor')
FavoriteStore  = require('stores/favorite_store.cursor')
UserStore      = require('stores/user_store.cursor')

ReactCSSTransitionGroup = React.addons.CSSTransitionGroup

# Exports
#
module.exports = React.createClass

  displayName: 'WelcomeTourCompanies'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      companies: ->
        """
          Viewer {
            roles,
            published_companies {
              #{CompanyPreview.getQuery('company')}
            }
          }
        """

  propTypes:
    className: React.PropTypes.string
    onNext:    React.PropTypes.func

  getDefaultProps: ->
    cursor:
      favorites: FavoriteStore.cursor.items
      user:      UserStore.me()


  # Helpers
  #
  getFavorites: ->
    FavoriteStore.filter (favorite) => 
      favorite.get('favoritable_type') == 'Company' &&
      favorite.get('user_id') == @props.cursor.user.get('uuid')

  getCompanies: ->
    favoritesIds = @getFavorites().map (favorite) -> favorite.get('favoritable_id')
    ownedCompaniesIds = CompanyStore
      .filterForUser(@props.cursor.user.get('uuid'))
      .map (company) -> company.get('uuid')

    CompanyStore
      .filter (company) -> company.get('is_published') && 
                           !favoritesIds.contains(company.get('uuid')) &&
                           !ownedCompaniesIds.contains(company.get('uuid'))
      .sortBy (company) -> company.get('created_at')
      .reverse()


  # Renderers
  #
  renderCompanies: ->
    @getCompanies().map (company, index) =>
      <CompanyPreview
        key              = { index }
        uuid             = { company.get('uuid') } />
    .toArray()

  renderPlaceholder: ->
    return null if @getCompanies().size

    <div className="placeholder">
      <p>You are already following all the companies we have.</p>
    </div>


  render: ->
    <article className={ "tour-companies " + @props.className }>
      <p>
        See how successful startups are growing. Follow companies you're interested in to get their updates and insights.
      </p>
      <ReactCSSTransitionGroup component={ React.DOM.section } className="companies-list" transitionName="company">
        { @renderCompanies() }
      </ReactCSSTransitionGroup>
      { @renderPlaceholder() }
    </article>
