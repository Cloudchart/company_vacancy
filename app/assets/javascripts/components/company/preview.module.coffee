# @cjsx React.DOM

GlobalState    = require('global_state/state')

ActivityStore  = require('stores/activity_store')
CompanyStore   = require('stores/company_store.cursor')
BlockStore     = require('stores/block_store.cursor')
PostStore      = require('stores/post_store.cursor')
PinStore       = require('stores/pin_store')
RoleStore      = require('stores/role_store.cursor')
FavoriteStore  = require('stores/favorite_store.cursor')
UserStore      = require('stores/user_store.cursor')

ActivitySyncApi = require('sync/activity_sync_api')
CompanySyncApi  = require('sync/company')

Logo           = require('components/company/logo')
People         = require('components/pinnable/block/people')
ModalStack     = require('components/modal_stack')
ModalError     = require('components/error/modal')

InviteActions  = require('components/roles/invite_actions')

Buttons        = require('components/form/buttons')

pluralize      = require('utils/pluralize')

SyncButton     = Buttons.SyncButton
CancelButton   = Buttons.CancelButton
AuthButton     = Buttons.AuthButton

Constants      = require('constants')

CompanyPreview = React.createClass

  displayName: 'CompanyPreview'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      company: ->
        """
          Company {
            #{InviteActions.getQuery('owner', 'Company')},
            staff,
            edges {
              posts_count,
              insights_count,
              is_followed,
              is_invited,
              staff_ids
            }
          }
        """

      favorites: ->
        """
          Company {
            edges {
              favorites,
              is_followed
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('company'), { id: @props.uuid }).then =>
      @setState
        fetched: true



  fetchFavorites: ->
    GlobalState.fetch(@getQuery('favorites'), { id: @props.uuid, force: true })


  # Component specifications
  #
  propTypes:
    uuid:             React.PropTypes.string.isRequired


  getDefaultProps: ->
    cursor:
      activities: ActivityStore.cursor.items
      roles:      RoleStore.cursor.items


  getInitialState: ->
    sync:     Immutable.Map()
    fetched:  false


  # Helpers
  #

  getStrippedDescription: ->
    return "" unless @cursor.company.get('description')

    description = @cursor.company.get('description').replace(/(<([^>]+)>)/ig, " ").trim()

    if description.length > 170
      description = description.slice(0, 170) + "..."

    description


  getFavorite: ->
    @cursor.company.get('is_followed')


  getPeopleIds: ->
    @cursor.company.get('staff_ids')
      .take(5)
      .toSeq()


  getPostsCount: ->
    @cursor.company.get('posts_count')


  getInsightsCount: ->
    @cursor.company.get('insights_count')


  isViewerOwner: ->
    true
    # !!CompanyStore
    #   .filterForUser(@cursor.viewer.get('uuid'))
    #   .filter (company) => company.get('uuid') == @props.uuid
    #   .size

  isUnpublished: ->
    !@cursor.company.get('is_published') && !@isViewerOwner() && !@cursor.company.get('is_invited')

  getPreviewLink: ->
    @cursor.company.get('company_url') unless @isUnpublished()

  isClickedByViewer: ->
    !!ActivityStore
      .filter (activity) =>
        activity.get('user_id') == @cursor.viewer.get('uuid') &&
        activity.get('action') == 'click' &&
        activity.get('trackable_id') == @props.uuid
      .size


  # Handlers
  #
  handleFollowClick: (event) ->
    event.preventDefault()
    event.stopPropagation()

    @setState(sync: @state.sync.set('follow', true))

    CompanySyncApi.follow(@cursor.company.get('uuid'), @handleFollowDone, @handleFollowFail)


  handleFollowDone: ->
    # TODO rewrite with grabbing only needed favorite
    @fetchFavorites(force: true).then =>
      @setState(sync: @state.sync.set('follow', false))

  handleFollowFail: ->
    @setState(sync: @state.sync.set('follow', false))

    ModalStack.show(<ModalError />)

  handlePreviewClick: ->
    return unless @isUnpublished()

    @setState sync: @state.sync.set('company_click', true)

    ActivitySyncApi.create(Immutable.Map(
      action:         'click'
      trackable_id:   @props.uuid
      trackable_type: 'Company'
    )).then @handleActivityCreateDone, @handleActivityCreateFail

  handleActivityCreateDone: (data) ->
    GlobalState.fetch(@getQuery('viewer')).then =>
      @setState sync: @state.sync.set('company_click', false)

      ModalStack.show(
        <section className="info-modal">
          <header>{ @cursor.company.get('name') }</header>
          <p>This company is not on { Constants.SITE_NAME } yet. But we've recorded, that you've been interested and will inform you when it will appear.</p>
          <button className="cc" onClick={ ModalStack.hide }>
            Got it
          </button>
        </section>
      )

  handleActivityCreateFail: ->
    @setState sync: @state.sync.set('company_click', false)

    ModalStack.show(<ModalError />)



  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      activities: ActivityStore.cursor.items
      blocks:     BlockStore.cursor.items
      company:    CompanyStore.cursor.items.cursor(@props.uuid)
      posts:      PostStore.cursor.items
      pins:       PinStore.cursor.items
      favorites:  FavoriteStore.cursor.items
      viewer:     UserStore.me()

    @fetch()


  renderInvitedLabel: ->
    return null unless @cursor.company.get('is_invited')

    <li className="label">Invited</li>

  renderFollowButton: ->
    return null unless !@getFavorite()

    <li>
      <AuthButton>
        <SyncButton
          className = "cc follow"
          onClick   = { @handleFollowClick }
          sync      = { @state.sync.get('follow') }
          text      = "Follow"
        />
      </AuthButton>
    </li>

  renderFollowedLabel: ->
    return null unless @getFavorite()

    <li className="label">Following</li>

  renderPostsCount: ->
    return null if (count = @getPostsCount()) == 0

    <li>
      { pluralize(count, "post", "posts") }
    </li>

  renderInsightsCount: ->
    return null if (count = @getInsightsCount()) == 0

    <li>
      { pluralize(count || 0, "insight", "insights") }
    </li>

  renderInfo: ->
    <div className="info">
      <ul className="stats">
        { @renderInsightsCount() }
        { @renderPostsCount() }
      </ul>
      <ul className="labels">
        { @renderInvitedLabel() }
        { @renderFollowButton() }
        { @renderFollowedLabel() }
      </ul>
    </div>

  renderHeader: ->
    company = @cursor.company

    <header>
      <Logo
        logoUrl = { company.get('logotype_url') }
        value   = { company.get('name') } />
      <h1>{ company.get('name') }</h1>
    </header>


  renderButtonsOrPeople: ->
    if @cursor.company.get('is_invited')
      <InviteActions ownerId = { @props.uuid } ownerType = 'Company' />
    else
      <People
        key            = "people"
        ids            = { @getPeopleIds() }
        showOccupation = { false }
        showLink       = { false } />


  renderFooter: ->
    <footer>
      { @renderButtonsOrPeople() }
    </footer>


  render: ->
    return null unless @state.fetched

    article_classes = cx
      'company-preview': true
      'cloud-card': true

    <article className={ article_classes }>
      <a href={ @getPreviewLink() } className="company-preview-link for-group">
        { @renderHeader() }
        { @renderInfo() }
        <p className="description">
          { @getStrippedDescription() }
        </p>
        { @renderFooter() }
      </a>
    </article>


module.exports = CompanyPreview
