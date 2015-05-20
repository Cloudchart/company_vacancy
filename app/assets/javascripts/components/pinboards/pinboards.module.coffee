# @cjsx React.DOM

GlobalState       = require('global_state/state')


# Stores
#
PinboardStore     = require('stores/pinboard_store')


# Components
#
PinboardComponent  = require('components/pinboards/pinboard')


NodeRepositioner   = require('utils/node_repositioner')


# Exports
#
module.exports = React.createClass


  displayName: 'Pinboards'

  mixins: [GlobalState.mixin, GlobalState.query.mixin, NodeRepositioner.mixin]

  statics:

    queries:

      pinboards: ->
        """
          Viewer {
            pinboards {
              #{PinboardComponent.getQuery('pinboard')}
            },

            roles {
              pinboard {
                #{PinboardComponent.getQuery('pinboard')}
              }
            }
          }
        """

  propTypes:
    uuid: React.PropTypes.string

  getDefaultProps: ->
    uuid: null

  getInitialState: ->
    loaders: Immutable.Map()

  fetch: ->
    GlobalState.fetch(@getQuery('pinboards')).then =>
      @setState
        loaders: @state.loaders.set('pinboards', true)

  isLoaded: ->
    @state.loaders.get('pinboards')


  # Helpers
  #
  gatherPinboards: ->
    @cursor.pinboards
      .sortBy (item) -> item.get('title')
      .valueSeq()


  # Lifecyle methods
  #
  componentWillMount: ->
    @cursor =
      pinboards: PinboardStore.cursor.items

    @fetch() unless @isLoaded()


  # Renderers
  #
  renderPinboard: (pinboard) ->
    <section className="cloud-column" key={ pinboard.get('uuid') }>
      <PinboardComponent uuid={ pinboard.get('uuid') } />
    </section>

  renderPinboards: ->
    @gatherPinboards().map(@renderPinboard)


  render: ->
    <section className="pinboards cloud-columns cloud-columns-flex">
      { @renderPinboards().toArray() }
    </section>
