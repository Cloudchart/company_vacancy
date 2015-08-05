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


  # Helpers
  #
  fetch: ->
    GlobalState.fetch(UserPinboards.getQuery('pinboards'), id: @props.user_id)

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
        { @renderHeader() }
        <UserPinboards user_id = { @props.user_id } showPrivate = { true } />
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
