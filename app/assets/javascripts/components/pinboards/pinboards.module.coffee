# @cjsx React.DOM

GlobalState = require('global_state/state')


# Stores
#
PinboardStore   = require('stores/pinboard_store')


# Components
#
PinboardComponent = require('components/pinboards/pinboard')


# Exports
#
module.exports = React.createClass


  displayName: 'Pinboards'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:

    queries:

      pinboards: ->
        """
          Viewer {
            readable_pinboards {
              #{PinboardComponent.getQuery('pinboard')}
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('pinboards')).then =>
      @setState
        loaders: @state.loaders.set('pinboards', true)


  isLoaded: ->
    @state.loaders.get('pinboards') == true


  gatherPinboards: ->
    @cursor.pinboards
      .sortBy (item) -> item.get('title')


  componentWillMount: ->
    @cursor =
      pinboards: PinboardStore.cursor.items

    @fetch() unless @isLoaded()


  getInitialState: ->
    loaders: Immutable.Map()


  renderPinboard: (pinboard) ->
    <li key={ pinboard.get('uuid') }>
      <PinboardComponent key={ pinboard.get('uuid') } uuid={ pinboard.get('uuid') } mode="list" />
    </li>


  renderPinboards: ->
    @gatherPinboards().map(@renderPinboard)


  render: ->
    return null unless @isLoaded()

    <section>
      <ul>
        { @renderPinboards().toArray() }
      </ul>
    </section>
