# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinboardStore = require('stores/pinboard_store')
PinStore      = require('stores/pin_store')


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


  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.uuid }).then =>


  isLoaded: ->
    @cursor.pinboard.deref(false)


  gatherPins: ->
    @cursor.pins
      .sortBy (pin) -> pin.get('created_at')
      .reverse()
      .valueSeq()
      .groupBy (pin, i) => i % @props.columns


  componentWillMount: ->
    @cursor =
      pinboard: PinboardStore.cursor.items.cursor(@props.uuid)
      pins:     PinStore.cursor.items.filterCursor (item) => item.get('pinboard_id') is @props.uuid

    @fetch() unless @isLoaded()


  getDefaultProps: ->
    columns: 2


  renderPin: (pin) ->
    <li key={ pin.get('uuid') }>
      <PinComponent key={ pin.get('uuid') } uuid={ pin.get('uuid') } />
    </li>



  renderPinsGroup: (pins, index) ->
    <ul key={ index }>
      { pins.map(@renderPin).toArray() }
    </ul>



  renderPins: ->
    @gatherPins().map(@renderPinsGroup)


  render: ->
    return null unless @isLoaded()

    <section className="list">
      { @renderPins().toArray() }
    </section>
