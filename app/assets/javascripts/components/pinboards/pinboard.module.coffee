# @cjsx React.DOM

GlobalState = require('global_state/state')


# Stores
#
PinboardStore   = require('stores/pinboard_store')


# Exports
#
module.exports = React.createClass


  displayName: 'PinboardPreview'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:

    queries:

      pinboard: ->
        """
          Pinboard {
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.uuid }).then =>
      @setState
        loaders: @state.loaders.set('pinboard', true)


  isLoaded: ->
    @cursor.pinboard.deref(false)


  componentWillMount: ->
    @cursor =
      pinboard: PinboardStore.cursor.items.cursor(@props.uuid)

    @fetch() unless @isLoaded()


  getInitialState: ->
    loaders: Immutable.Map()


  renderHeader: ->
    <header>
      <span>
        { @cursor.pinboard.get('title') }
      </span>
      <span className="counter">
        { (count = @cursor.pinboard.get('pins_count')) + ' ' + if count == 1 then 'pin' else 'pins' }
      </span>
    </header>


  render: ->
    return null unless @isLoaded()

    <section className="pinboard">
      { @renderHeader() }
    </section>
