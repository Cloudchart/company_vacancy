# @cjsx React.DOM

GlobalState        = require('global_state/state')

ProfileInfo        = require('components/profile/info')
PinboardsComponent = require('components/pinboards/pinboards')
CompaniesList      = require('components/company/list')

UserStore          = require('stores/user_store.cursor')
FavoriteStore      = require('stores/favorite_store.cursor')

Button             = require('components/form/buttons').SyncButton

SyncApi            = require('sync/user_sync_api')

cx = React.addons.classSet

module.exports = React.createClass

  displayName: 'ProfileApp'

  # Component specifications
  #
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:
      user: ->
        """
          Viewer {
            favorites
          }
        """

  propTypes:
    uuid:     React.PropTypes.string.isRequired

  getDefaultProps: ->
    cursor: FavoriteStore.cursor.items

  getInitialState: ->
    selected:   location.hash.substr(1) || 'pins' || ''
    isSyncing:  false

  fetch: ->
    GlobalState.fetch(@getQuery('user'), force: true)

  getStateFromStores: ->
    favorite: FavoriteStore.findByUser(@props.uuid)

  onGlobalStateChange: ->
    @setState  @getStateFromStores()


  # Helpers
  #
  isLoaded: ->
    @cursor.user.deref(false)

  getMenuOptionClassName: (option) ->
    cx(active: @state.selected == option)

  getFavorite: ->
    @state.favorite


  # Handlers
  #
  handleMenuClick: (selected) ->
    @setState selected: selected
    location.hash = selected

  handleFollowClick: ->
    @setState(isSyncing: true)

    if favorite = @getFavorite()
      SyncApi.unfollow(@props.uuid).then =>
        FavoriteStore.cursor.items.remove(favorite.get('uuid'))
        @setState(isSyncing: false)
    else
      SyncApi.follow(@props.uuid).then => 
        @fetch().then => @setState(isSyncing: false)



  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor = 
      user: UserStore.me()

    @fetch() unless @isLoaded()



  # Renderers
  #
  renderMenu: ->
    <nav>
      <ul>
        <li className = { @getMenuOptionClassName('pins') } onClick = { @handleMenuClick.bind(@, 'pins') } >Pins</li>
        <li className = { @getMenuOptionClassName('companies') } onClick = { @handleMenuClick.bind(@, 'companies') } >Companies</li>
      </ul>
    </nav>

  renderFollowButton: ->
    return null unless @isLoaded() && @cursor.user.get('email') && @cursor.user.get('uuid') != @props.uuid

    text = if @getFavorite() then 'Unfollow' else 'Follow'

    <Button 
      className         = "cc follow-button"
      onClick           = { @handleFollowClick }
      text              = { text }
      sync              = { @state.isSyncing }
      showSyncAnimation = { false } />

  renderContent: ->
    if @state.selected == "pins"
      <PinboardsComponent uuid = { @props.uuid } />
    else if @state.selected = "companies"
      <CompaniesList uuid = { @props.uuid } />


  render: ->
    <section className="user-profile">
      <header>
        <div className="cloud-columns cloud-columns-flex">
          <ProfileInfo uuid = { @props.uuid } />
          { @renderMenu() }
          { @renderFollowButton() }
        </div>
      </header>
      { @renderContent() }
    </section>
