# @cjsx React.DOM

GlobalState   = require('global_state/state')

PinboardCard  = require('components/cards/pinboard_card')
PinboardList  = require('components/pinboards/lists/base')

PinboardStore = require('stores/pinboard_store')
UserStore     = require('stores/user_store.cursor')


# Exports
#
module.exports = React.createClass

  displayName: "PopularPinboards"


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:
    queries:
      viewer: ->
        """
          Viewer {
            popular_pinboards {
              #{PinboardCard.getQuery('pinboard')},
              edges {
                is_related
              }
            },
            edges {
              popular_pinboards_ids
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('viewer')).done =>
      @setState
        ready: true


  # Lifecycle
  #

  componentDidMount: ->
    @fetch()


  getDefaultProps: ->
    cursor:
      pinboards:  PinboardStore.cursor.items
      viewer:     UserStore.me()


  getInitialState: ->
    ready: false


  # Renders
  #

  renderHeader: ->
    <header className="cloud-columns cloud-columns-flex">
      <h1>
        Browse Collections
      </h1>
    </header>


  renderPinboard: (id) ->
    <PinboardCard key={ id } pinboard={ id } />


  renderPinboards: ->
    renderedPinboards = @props.cursor.viewer.get('popular_pinboards_ids', Immutable.Seq())
      .map (id) ->
        PinboardStore.get(id)
      .filter (pinboard) ->
        !pinboard.get('is_related')
      .map (pinboard) ->
        pinboard.get('id')
      .map @renderPinboard

    <PinboardList>
      { renderedPinboards.toArray() }
    </PinboardList>


  # Render
  #
  render: ->
    return null unless @state.ready
    return null unless @props.cursor.viewer.get('popular_pinboards_ids', Immutable.Seq()).size > 0

    <section className="cc-container-common">
      { @renderHeader() }
      { @renderPinboards() }
    </section>
