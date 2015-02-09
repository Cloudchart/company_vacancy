# @cjsx React.DOM

GlobalState = require('global_state/state')
cx          = React.addons.classSet


# Stores
#
PinboardStore = require('stores/pinboard_store')
PinStore      = require('stores/pin_store')


# Components
#
PinComponent = require('components/pinboards/pin')


# Exports
#
module.exports = React.createClass


  displayName: 'Pinboard'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:

    queries:

      pinboard: ->
        """
          Pinboard {
            pins {
              #{PinComponent.getQuery('pin')}
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.uuid })


  isLoaded: ->
    @cursor.pinboard.deref(false)


  gatherPins: ->
    pins = @cursor.pins
      .sortBy (pin) -> pin.get('created_at')
      .reverse()

    pins = pins.take(@props.pin_count) if @props.mode == 'list'

    pins


  handleClick: (event) ->
    return unless @props.mode == 'list'

    event.preventDefault()
    location.href = @cursor.pinboard.get('url')



  componentWillMount: ->
    @cursor =
      pinboard: PinboardStore.cursor.items.cursor(@props.uuid)
      pins:     PinStore.cursor.items.filterCursor (pin) => pin.get('pinboard_id') == @props.uuid

    @fetch() unless @isLoaded()


  getDefaultProps: ->
    pin_count:  1
    cursor:     {}


  renderPin: (pin) ->
    <li key={ pin.get('uuid') } uuid={ pin.get('uuid') }>
      <PinComponent uuid={ pin.get('uuid') } />
    </li>


  renderPins: ->
    @gatherPins().map(@renderPin)


  renderHeader: ->
    return null unless @props.mode == 'list'

    <header>
      { @cursor.pinboard.get('title') }
      { " :: "}
      { @cursor.pins.count() + " " + if @cursor.pins.count() == 1 then "pin" else "pins" }
    </header>


  render: ->
    return null unless @isLoaded()

    classList = cx
      linked: @props.mode == 'list'

    <section className={ classList } onClick={ @handleClick }>
      { @renderHeader() }
      <ul>
        { @renderPins().toArray() }
      </ul>
    </section>
