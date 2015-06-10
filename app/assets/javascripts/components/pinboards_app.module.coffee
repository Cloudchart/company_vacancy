# @cjsx React.DOM


# Components
#
GlobalState       = require('global_state/state')

UserPinboards  = require('components/pinboards/lists/user')
StandardButton = require('components/form/buttons').StandardButton

NewPinboard    = require('components/pinboards/new_pinboard')

ModalStack     = require('components/modal_stack')

PinboardStore      = require('stores/pinboard_store')
FavoriteStore      = require('stores/favorite_store.cursor')
SuggestedPinboards = require('components/pinboards/lists/suggested')


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
    @fetch().then(=> @setState isLoaded: true) unless @isLoaded()


  # Renderers
  #
  renderSuggestedInsights: ->
    return null if @getUserPinboards().size >= 3

    <SuggestedPinboards />


  render: ->
    if @isLoaded()
      <section className="pinboards-wrapper">
        <header className="cloud-columns cloud-columns-flex">
          Your collections
          <StandardButton
            className = "cc"
            onClick   = { @handleCreateCollectionClick }
            text      = "Create collection" />
        </header>
        <UserPinboards user_id = { @props.user_id } showPrivate = { true } />
        { @renderSuggestedInsights() }
      </section>
    else
      null