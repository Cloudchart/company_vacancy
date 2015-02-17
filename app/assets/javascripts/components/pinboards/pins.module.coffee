# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinboardStore = require('stores/pinboard_store')
PinStore      = require('stores/pin_store')
UserStore     = require('stores/user_store.cursor')


# Components
#
PinComponent  = require('components/pinboards/pin')
PostComponent = require('components/pinnable/post')


# Exports
#
module.exports = React.createClass

  displayName: 'Pins'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:

    queries:

      pinboard: ->
        """
          Pinboard {
            posts {
              blocks,
              owner
            },
            pins {
              #{PinComponent.getQuery('pin')}
            }
          }
        """

      me: ->
        """
          Viewer
        """


  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.uuid })
    GlobalState.fetch(@getQuery('me'))


  isLoaded: ->
    @cursor.pinboard.deref(false) and @cursor.me.deref(false)


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

          node.style.top  = '-' + delta + 'px'


  gatherPins: ->
    @cursor.pins
      .sortBy (pin) -> pin.get('created_at')
      .reverse()
      .valueSeq()


  componentWillMount: ->
    @cursor =
      pinboard: PinboardStore.cursor.items.cursor(@props.uuid)
      pins:     PinStore.cursor.items.filterCursor (item) => item.get('pinboard_id') is @props.uuid
      me:       UserStore.me()

    @fetch() unless @isLoaded()


  componentDidUpdate: ->
    @repositionNodes()


  getDefaultProps: ->
    columns: 2


  renderPin: (pin) ->
    <section className="cloud-column" key={ pin.get('uuid') }>
      <PinComponent key={ pin.get('uuid') } uuid={ pin.get('uuid') } />
    </section>



  renderPins: ->
    @gatherPins().map(@renderPin)


  render: ->
    return null unless @isLoaded()

    <section className="cloud-columns cloud-columns-flex">
      { @renderPins().toArray() }
    </section>
