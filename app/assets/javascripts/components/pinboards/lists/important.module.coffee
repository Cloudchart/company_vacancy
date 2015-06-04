# @cjsx React.DOM

GlobalState       = require('global_state/state')


# Stores
#
PinboardStore     = require('stores/pinboard_store')
RoleStore         = require('stores/role_store.cursor')


# Components
#
PinboardComponent  = require('components/pinboards/pinboard')
PinboardsList      = require('components/pinboards/pinboards')


# Exports
#
module.exports = React.createClass


  displayName: 'ImportantPinboards'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

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

  getInitialState: ->
    isLoaded: false

  fetch: ->
    GlobalState.fetch(@getQuery('pinboards'))


  # Helpers
  #
  isLoaded: ->
    @state.isLoaded


  # Helpers
  #
  gatherPinboards: ->
    PinboardStore
      .filter (pinboard) -> pinboard.get('is_important')
      .sortBy (item) -> item.get('created_at')
      .reverse()
      .take(4)
      .valueSeq()
      .toArray()


  # Lifecyle methods
  #
  componentWillMount: ->
    @fetch().then => @setState isLoaded: true


  render: ->
    return null unless @isLoaded()

    <PinboardsList 
      pinboards = { @gatherPinboards() } />
