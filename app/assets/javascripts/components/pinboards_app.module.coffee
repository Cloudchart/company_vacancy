# @cjsx React.DOM

GlobalState     = require('global_state/state')


# Stores
#
PinboardStore = require('stores/pinboard_store')
UserStore     = require('stores/user_store.cursor')


# Exports
#
module.exports = React.createClass

  displayName: 'PinboardsApp'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:
    queries:

      main: ->
        """
          Viewer {
            roles,
            readable_pinboards {
              pins {
                user,
                parent {
                  user
                }
              }
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('main')).then =>
      @setState
        loaders: @state.loaders.set('main', true)


  isLoaded: ->
    @state.loaders.get('main') == true


  componentWillMount: ->
    @fetch()


  getDefaultProps: ->
    cursor:
      pinboards: PinboardStore.readable_pinboards(UserStore.me())


  getInitialState: ->
    loaders: Immutable.Map()


  render: ->
    return null unless @isLoaded()

    console.log @props.cursor.pinboards.count()

    null
