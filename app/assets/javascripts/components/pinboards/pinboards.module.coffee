# @cjsx React.DOM

GlobalState   = require('global_state/state')


# Stores
#
PinboardStore   = require('stores/pinboard_store')


# Components
#
PinboardComponent  = require('components/pinboards/pinboard')


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
      .valueSeq()


  handleClick: (pinboard, event) ->
    event.preventDefault()
    document.location = pinboard.get('url')


  componentWillMount: ->
    @cursor =
      pinboards: PinboardStore.cursor.items

    @fetch() unless @isLoaded()


  getInitialState: ->
    loaders: Immutable.Map()


  renderPinboard: (pinboard) ->
    <li key={ pinboard.get('uuid') } className="link" onClick={ @handleClick.bind(null, pinboard) }>
      <PinboardComponent uuid={ pinboard.get('uuid') } />
    </li>


  renderPinboards: ->
    <ul>
      { @gatherPinboards().map(@renderPinboard).toArray() }
    </ul>


  render: ->
    return null unless @isLoaded()

    <section className="cloud-columns">
      { @renderPinboards() }
    </section>
