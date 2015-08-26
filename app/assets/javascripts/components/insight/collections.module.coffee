# @cjsx React.DOM

# Imports
#

GlobalState   = require('global_state/state')

PinStore      = require('stores/pin_store')
PinboardStore = require('stores/pinboard_store')

Collection    = require('components/insight/collection')


# Exports
#
module.exports = React.createClass

  displayName: 'InsightConnectedCollectionList'

  propTypes:
    pin: React.PropTypes.string.isRequired

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  getInitialState: ->
    ready: false


  statics:
    queries:
      pin: ->
        """
          Pin {
            connected_collections {
              #{Collection.getQuery('collection')},
              edges {
                readers_count
              }
            },
            edges {
              connected_collections_ids
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.pin }).then =>
      @setState
        ready:  true
        pin:    @cursor.pin.deref().toJS()


  # Lifecycle
  #
  onGlobalStateChange: ->
    @setState
      pin: @cursor.pin.deref().toJS()


  componentWillMount: ->
    @cursor =
      pin: PinStore.cursor.items.cursor(@props.pin)


  componentDidMount: ->
    @fetch()


  # Render
  #

  renderCollection: (collection) ->
    <li key={ collection.id }>
      <Collection collection={ collection.id } />
    </li>


  renderCollections: ->
    Immutable.Seq(@state.pin.connected_collections_ids)
      .toSet()
      .map (id) -> PinboardStore.get(id).toJS()
      .sortBy (collection) -> - collection.readers_count
      .map @renderCollection
      .toArray()


  render: ->
    return null unless @state.ready

    <ul className="collections">
      { @renderCollections() }
    </ul>
