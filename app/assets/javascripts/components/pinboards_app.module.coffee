# @cjsx React.DOM

# Components
#
GlobalState = require('global_state/state')

PinboardStore = require('stores/pinboard_store')
FavoriteStore = require('stores/favorite_store.cursor')
UserStore = require('stores/user_store.cursor')

UserPinboards = require('components/pinboards/lists/user')
StandardButton = require('components/form/buttons').StandardButton
NewPinboard = require('components/pinboards/new_pinboard')
ModalStack = require('components/modal_stack')
PopularPinboards = require('components/pinboards/lists/popular')
FeaturedPinboard = require('components/landing/featured_pinboard')


# Exports
#
module.exports = React.createClass

  displayName: 'PinboardsApp'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    user_id: React.PropTypes.string.isRequired

  getInitialState: ->
    isLoaded: false

  getDefaultProps: ->
    cursor:
      favorites: FavoriteStore.cursor.items
      pinboards: PinboardStore.cursor.items

  statics:
    queries:
      viewer: ->
        """
          Viewer {
            main_feature {
              featurable_pinboard {
                #{FeaturedPinboard.getQuery('pinboard')}
              }
            }
          }
        """


  # Fetchers
  #
  fetch: ->
    Promise.all([
      @fetchViewer(),
      @fetchUserPinboards()
    ])

  fetchViewer: ->
    GlobalState.fetch(@getQuery('viewer')).done (json) => @setState(featured_pinboard_id: json.query.main_feature.featurable_pinboard.ids[0])


  fetchUserPinboards: ->
    GlobalState.fetch(UserPinboards.getQuery('pinboards'), id: @props.user_id)


  # Helpers
  #
  isLoaded: ->
    @state.isLoaded

  getUserPinboards: ->
    PinboardStore.filterUserPinboards(@props.user_id)


  # Handlers
  #
  handleCreateCollectionClick: ->
    ModalStack.show(
      <NewPinboard user_id = { @props.user_id } />
    )


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      user: UserStore.cursor.items.cursor(@props.user_id)

    @fetch().then(=> @setState isLoaded: true, initialUserPinboardsCount: @getUserPinboards().size) unless @isLoaded()


  # Renderers
  #
  renderFeaturedPinboard: ->
    return null unless featured_pinboard_id = @state.featured_pinboard_id
    <FeaturedPinboard pinboard={ featured_pinboard_id } scope='main' />

  renderPopularPinboards: ->
    <PopularPinboards />

  renderHeader: ->
    return null unless @cursor.user.get('twitter')

    title = if @getUserPinboards().size > 0
      <span>Your collections</span>
    else
      <span>Your collections are empty</span>

    <header className="cloud-columns cloud-columns-flex">
      { title }
      <StandardButton
        className = "cc"
        onClick   = { @handleCreateCollectionClick }
        text      = "Create collection" />
    </header>


  # Main render
  #
  render: ->
    if @isLoaded()
      <section className="pinboards-wrapper">
        { @renderFeaturedPinboard() }
        { @renderHeader() }
        <UserPinboards user_id = { @props.user_id } showPrivate = { true } />
        { @renderPopularPinboards() }
      </section>
    else
       <section className="pinboards-wrapper">
        <section className="pinboards cloud-columns cloud-columns-flex">
          <section className="cloud-column">
            <section className="pinboard cloud-card placeholder" />
          </section>
          <section className="cloud-column">
            <section className="pinboard cloud-card placeholder" />
          </section>
        </section>
      </section>
