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


  displayName: 'UserPinboards'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      pinboards: ->
        """
          User {
            pinboards {
              #{PinboardComponent.getQuery('pinboard')}
            },

            favorites {
              pinboard {
                #{PinboardComponent.getQuery('pinboard')}
              }
            },

            roles {
              pinboard {
                #{PinboardComponent.getQuery('pinboard')}
              }
            }
          }
        """

    isEmpty: (user_id, options={}) ->
      !PinboardStore.filterUserPinboards(user_id, showPrivate: options.showPrivate).size

  propTypes:
    user_id:     React.PropTypes.string
    showPrivate: React.PropTypes.bool

  getDefaultProps: ->
    cursor:
      pinboards: PinboardStore.cursor.items
      roles:     RoleStore.cursor.items
    showPrivate: false

  getInitialState: ->
    loaders: Immutable.Map()

  fetch: ->
    GlobalState.fetch(@getQuery('pinboards'), id: @props.user_id)


  # Helpers
  #
  isLoaded: ->
    @state.isLoaded


  # Helpers
  #
  gatherPinboards: ->
    PinboardStore
      .filterUserPinboards(@props.user_id, showPrivate: @props.showPrivate)
      .sortBy (item) -> item.get('title')
      .valueSeq()
      .toArray()


  # Lifecyle methods
  #
  componentWillMount: ->
    @fetch().then(=> @setState isLoaded: true) unless @isLoaded()


  render: ->
    return null unless @isLoaded()

    <PinboardsList 
      pinboards = { @gatherPinboards() }
      user_id   = { @props.user_id } />
