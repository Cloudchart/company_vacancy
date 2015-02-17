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
            pinboards {
              #{PinboardComponent.getQuery('pinboard')}
            },

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


  repositionNodes: ->
    return unless parentNode = @getDOMNode()

    Immutable.Seq(parentNode.childNodes)
      .groupBy (node) ->
        node.getBoundingClientRect().left

      .forEach (nodes) ->
        nodes.forEach (node, i) ->
          return if i == 0

          bounds          = node.getBoundingClientRect()
          prevNode        = nodes.get(i - 1)
          prevNodeBounds  = prevNode.getBoundingClientRect()

          delta           = bounds.top - prevNodeBounds.bottom

          node.style.top  = '-' + delta + 'px' unless delta == 0


  gatherPinboards: ->
    @cursor.pinboards
      .sortBy (item) -> item.get('title')
      .valueSeq()


  componentWillMount: ->
    @cursor =
      pinboards: PinboardStore.cursor.items

    @fetch() unless @isLoaded()


  componentDidMount: ->
    @repositionNodes()


  componentDidUpdate: ->
    @repositionNodes()


  getInitialState: ->
    loaders: Immutable.Map()


  renderPinboard: (pinboard) ->
    <section className="cloud-column" key={ pinboard.get('uuid') }>
      <PinboardComponent uuid={ pinboard.get('uuid') } />
    </section>


  renderPinboards: ->
    @gatherPinboards().map(@renderPinboard)


  render: ->
    return null unless @isLoaded()

    <section className="cloud-columns cloud-columns-flex">
      { @renderPinboards().toArray() }
    </section>
