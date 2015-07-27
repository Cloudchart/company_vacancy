# @cjsx React.DOM

GlobalState = require('global_state/state')

UserStore = require('stores/user_store.cursor')
PinboardStore = require('stores/pinboard_store')
PinStore = require('stores/pin_store')

InsightCard = require('components/cards/insight_card_')
Pinboard = require('components/cards/pinboard_card')

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
              #{InsightCard.getQuery('pin')}
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
      # pins: PinStore.cursor.items
      # pinboards: PinboardStore.cursor.items

  getInitialState: ->
    ready: false


  # Lifecycle Methods
  #
  componentWillMount: ->
    @fetch()

  # componentDidMount: ->
  # componentWillUnmount: ->
  conponentWillReceiveProps: (nextProps) ->
    fetch(nextProps.date) if nextProps.date and nextProps.date isnt @props.date



  # Fetchers
  #
  fetch: (date = @props.date) ->
    GlobalState.fetch(@getQuery('viewer'), { force: true, params: { date: @props.date } }).then => @setState(ready: true)


  # Helpers
  #
  getMainListCollection: ->
    result = new Array

    Object.keys(ObjectsForMainList).forEach (key) =>
      @props.cursor.user.deref(Immutable.Seq()).get("related_#{key}_by_date")
        .forEach (object) => result.push(
          id: object.get('id')
          type: ObjectsForMainList[key]
          created_at: object.get('created_at')
          # data: @props.cursor[key].get(object.get('id')).toJS() # do we need data here?
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
      .sortBy (object) -> object.created_at
      .reverse()
      .map (object, index) ->
        switch object.type
          when 'Pin'
            <section key={ index } className="cloud-column">
              <InsightCard pin = { object.id }/>
            </section>
          when 'Pinboard'
            <section key={ index } className="cloud-column">
              <Pinboard pinboard = { object.id } />
            </section>
      .toArray()


  # Main render
  #
  render: ->
    return @renderPlaceholders() unless @state.ready

    <section className="cloud-columns cloud-columns-flex">
      { @renderMainList() }
    </section>
