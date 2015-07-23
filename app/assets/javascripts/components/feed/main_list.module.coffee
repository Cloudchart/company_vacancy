# @cjsx React.DOM

GlobalState = require('global_state/state')

Pin = require('components/cards/pin_card')
Pinboard = require('components/cards/pinboard_card')

UserStore = require('stores/user_store.cursor')
PinboardStore = require('stores/pinboard_store')
PinStore = require('stores/pin_store')


# Utils
#
# cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'FeedMainList'

  # propTypes:
    # some_object: React.PropTypes.object.isRequired

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      viewer: ->
        """
          Viewer {
            related_pins_by_date {
              #{Pin.getQuery('pin')}
            },
            related_pinboards_by_date {
              #{Pinboard.getQuery('pinboard')}
            },
            edges {
              related_pins_by_date,
              related_pinboards_by_date
            }
          }
        """

  # Component Specifications
  #
  getDefaultProps: ->
    cursor:
      user: UserStore.me()
      pins: PinStore.cursor.items
      pinboards: PinboardStore.cursor.items

  getInitialState: ->
    ready: false


  # Lifecycle Methods
  #
  componentWillMount: ->
    @fetch()

  # componentDidMount: ->
  # componentWillUnmount: ->


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('viewer')).then => @setState(ready: true)


  # Helpers
  #
  # getSomething: ->


  # Handlers
  #
  # handleThingClick: (event) ->


  # Renderers
  #
  renderPlaceholders: ->
    <div className="">placeholders</div>


  # Main render
  #
  render: ->
    return @renderPlaceholders() unless @state.ready
    # console.log @props.cursor.pins.deref(Immutable.Seq()).toJS()
    # console.log @props.cursor.pinboards.deref(Immutable.Seq()).toJS()
    console.log @props.cursor.user.deref(Immutable.Seq()).toJS()
    <div className=""></div>
