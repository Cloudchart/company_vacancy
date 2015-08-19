# @cjsx React.DOM

# Imports
#

GlobalState   = require('global_state/state')

UserStore     = require('stores/user_store.cursor')
PinboardStore = require('stores/pinboard_store')

pluralize     = require('utils/pluralize')


# Exports
#
module.exports = React.createClass

  displayName: 'InsightConnectedCollection'

  propTypes:
    collection: React.PropTypes.string.isRequired

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  getInitialState: ->
    ready: false


  statics:
    queries:
      collection: ->
        """
          Pinboard {
            user {
              full_name
            },
            edges {
              pins_count
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('collection'), { id: @props.collection }).then =>
      @setState
        ready:        true
        collection:   @cursor.collection.deref().toJS()
        user:         UserStore.get(@cursor.collection.get('user_id')).toJS()


  # Lifecycle
  #
  onGlobalStateChange: ->
    @setState
      collection: @cursor.collection.deref().toJS()


  componentWillMount: ->
    @cursor =
      collection: PinboardStore.cursor.items.cursor(@props.collection)


  componentDidMount: ->
    @fetch()


  # Render
  #

  render: ->
    return null unless @state.ready

    <div className="collection">
      <section>
        <a href={ @state.collection.url } className="title see-through">{ @state.collection.title }</a>
        <span> by </span>
        <a href={ @state.user.url } className="author">{ @state.user.full_name }</a>
      </section>
      <footer>
        <div className="pins-count">{ pluralize(@state.collection.pins_count, 'insight', 'insights') }</div>
      </footer>
    </div>
