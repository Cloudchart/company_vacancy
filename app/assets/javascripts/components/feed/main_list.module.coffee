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

ObjectsForMainList =
  pins: 'Pin'
  pinboards: 'Pinboard'


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
  getMainListCollection: ->
    result = new Array

    Object.keys(ObjectsForMainList).forEach (key) =>
      @props.cursor.user.deref(Immutable.Seq()).get("related_#{key}_by_date")
        .forEach (object) => result.push(
          id: object.get('id')
          type: ObjectsForMainList[key]
          updated_at: object.get('updated_at')
          data: @props.cursor[key].get(object.get('id')).toJS()
        )

    result


  # Handlers
  #
  # handleThingClick: (event) ->


  # Renderers
  #
  renderPlaceholders: ->
    <div className="">placeholders</div>

  renderMainList: ->
    Immutable.List(@getMainListCollection())
      .sortBy (object) -> object.updated_at
      .reverse()
      .map (object, index) ->
        switch object.type
          when 'Pin'
            <div className="" key={index}>
              <Pin pin = { object.id } />
            </div>
          when 'Pinboard'
            <div className="" key={index}>
              <Pinboard pinboard = { object.id } />
            </div>
      .toArray()


  # Main render
  #
  render: ->
    return @renderPlaceholders() unless @state.ready

    <div className="main-list">
      { @renderMainList() }
    </div>
