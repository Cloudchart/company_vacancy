# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinStore = require('stores/pin_store')


# Components
#
Pinnables =
  'Post': require('components/pinnable/post')


# Exports
#
module.exports = React.createClass

  displayName: 'Pin'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:

    queries:

      pin: ->
        """
          Pin {
            pinnable,
            user,
            parent {
              user
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.uuid })


  isLoaded: ->
    @cursor.pin.deref(false)


  componentWillMount: ->
    @cursor =
      pin: PinStore.cursor.items.cursor(@props.uuid)

    @fetch() unless @isLoaded()


  getDefaultProps: ->
    cursor: {}


  renderHeader: ->
    <header>
      { @cursor.pin.get('pinnable_type') }
      { " :: " }
      { @cursor.pin.get('content') }
    </header>


  renderPinnable: ->
    Pinnables[@cursor.pin.get('pinnable_type')](uuid: @cursor.pin.get('pinnable_id'), pin: @cursor.pin)


  render: ->
    return null unless @isLoaded()

    <section>
      { @renderHeader() }
      { @renderPinnable() }
    </section>
