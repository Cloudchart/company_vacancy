# @cjsx React.DOM


GlobalState = require('global_state/state')


# Stores
#
PinStore = require('stores/pin_store')


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


  render: ->
    return null unless @isLoaded()

    <section>
      { @cursor.pin.get('pinnable_type') }
      { " :: " }
      { @cursor.pin.get('content') }
    </section>
