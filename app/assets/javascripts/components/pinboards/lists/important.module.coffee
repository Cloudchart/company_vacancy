# @cjsx React.DOM

GlobalState       = require('global_state/state')


# Stores
#
PinboardStore     = require('stores/pinboard_store')
RoleStore         = require('stores/role_store.cursor')
UserStore         = require('stores/user_store.cursor')


# Components
#
PinboardComponent  = require('components/pinboards/pinboard')
PinboardsList      = require('components/pinboards/pinboards')


# Exports
#
module.exports = React.createClass


  displayName: 'ImportantPinboards'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    filterSaved: React.PropTypes.bool

  statics:

    queries:

      pinboards: ->
        """
          Viewer {
            important_pinboards {
              #{PinboardComponent.getQuery('pinboard')}
            }
          }
        """

  getDefaultProps: ->
    cursor:
      pinboards: PinboardStore.cursor.items
    filterSaved: false

  getInitialState: ->
    isLoaded: false

  fetch: ->
    GlobalState.fetch(@getQuery('pinboards'))


  # Helpers
  #
  isLoaded: ->
    @state.isLoaded && @cursor.user.deref(false)


  # Helpers
  #
  gatherPinboards: ->
    pinboardIds = PinboardStore.filterUserPinboards(@cursor.user.get('uuid')).map (pinboard) -> pinboard.get('uuid')

    PinboardStore
      .filter (pinboard) => 
        pinboard.get('is_important') &&
        (!@props.filterSaved || !pinboardIds.contains(pinboard.get('uuid')))
      .sortBy (item) -> item.get('created_at')
      .reverse()
      .take(4)
      .valueSeq()
      .toArray()


  # Lifecyle methods
  #
  componentWillMount: ->
    @cursor =
      user: UserStore.me()

    @fetch().then => @setState isLoaded: true


  # Renderers
  #
  renderHeader: ->
    return null unless @props.header

    <header className="cloud-columns cloud-columns-flex">{ @props.header }</header>

  renderDescription: ->
    return null unless @props.description

    <p className="cloud-columns cloud-columns-flex">{ @props.description }</p>


  render: ->
    return null unless @isLoaded()

    <section className="featured-collections">
      { @renderHeader() }
      { @renderDescription() }
      <PinboardsList 
        pinboards = { @gatherPinboards() } />
    </section>
