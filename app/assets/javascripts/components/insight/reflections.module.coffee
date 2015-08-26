# @cjsx React.DOM

# Imports
#

GlobalState = require('global_state/state')
PinStore    = require('stores/pin_store')

Reflection  = require('components/insight/reflection')

# Exports
#
module.exports = React.createClass

  displayName: 'InsightReflections'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    insight: React.PropTypes.string.isRequired

  getInitialState: ->
    ready: false


  statics:
    queries:
      insight: ->
        """
          Pin {
            reflections {
              #{Reflection.getQuery('reflection')},
              edges {
                users_votes_count
              }
            },
            edges {
              reflection_ids
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('insight'), id: @props.insight).then =>
      @addCursor 'insight', PinStore.cursor.items.cursor(@props.insight)
      @setState
        ready: true


  componentDidMount: ->
    @fetch()


  renderReflection: (record) ->
    <li key={ record.id }>
      <Reflection reflection={ record.id } />
    </li>


  renderReflections: ->
    @getCursor('insight').get('reflections_ids')
      .map (id) -> PinStore.get(id).toJS()
      .sortBy (item) -> - item.users_votes_count
      .map @renderReflection
      .toArray()


  render: ->
    return null unless @state.ready

    <ul className="reflections">
      { @renderReflections() }
    </ul>
