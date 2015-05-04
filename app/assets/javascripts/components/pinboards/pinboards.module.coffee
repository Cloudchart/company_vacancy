# @cjsx React.DOM

GlobalState   = require('global_state/state')


# Stores
#
PinboardStore   = require('stores/pinboard_store')


# Components
#
PinboardComponent  = require('components/pinboards/pinboard')


MasonryMixin       = require('utils/masonry_mixin')


# Exports
#
module.exports = React.createClass


  displayName: 'Pinboards'

  mixins: [GlobalState.mixin, GlobalState.query.mixin, Masonrymixin]

  statics:

    queries:

      viewer_pinboards: ->
        """
          Viewer {
            pinboards {
              #{PinboardComponent.getQuery('pinboard')}
            },

            readable_pinboards {
              #{PinboardComponent.getQuery('pinboard')}
            }
          }
        """

      user_pinboards: ->
        """
          User {
            pinboards {
              #{PinboardComponent.getQuery('pinboard')}
            }
          }
        """

  propTypes:
    uuid: React.PropTypes.string

  getDefaultProps: ->
    uuid: null

  fetch: ->
    if @props.uuid
      promise = GlobalState.fetch(@getQuery('user_pinboards'), id: @props.uuid)
    else
      promise = GlobalState.fetch(@getQuery('viewer_pinboards'))

    promise.then =>
      @setState
        loaders: @state.loaders.set('pinboards', true)


  isLoaded: ->
    @state.loaders.get('pinboards')


  gatherPinboards: ->
    @cursor.pinboards
      .sortBy (item) -> item.get('title')
      .valueSeq()


  componentWillMount: ->
    @cursor =
      pinboards: PinboardStore.cursor.items

    @fetch() unless @isLoaded()


  getInitialState: ->
    loaders: Immutable.Map()


  renderPinboard: (pinboard) ->
    <section className="cloud-column" key={ pinboard.get('uuid') }>
      <PinboardComponent uuid={ pinboard.get('uuid') } />
    </section>


  renderPinboards: ->
    @gatherPinboards().map(@renderPinboard)


  render: ->
    return null unless @isLoaded()

    <section className="pinboards cloud-columns cloud-columns-flex">
      { @renderPinboards().toArray() }
    </section>
