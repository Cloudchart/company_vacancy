# @cjsx React.DOM


GlobalState = require('global_state/state')

PinStore    = require('stores/pin_store')

PinButton       = require('components/pinnable/pin_button')
EditPinButton   = require('components/pinnable/edit_pin_button')
SharePinButton  = require('components/insight/share_button')


# Exports
#
module.exports = React.createClass

  displayName: 'ProfileInsight'

  mixins: [GlobalState.query.mixin]

  statics:

    queries:

      insight: ->
        """
          Pin {
            user,
            edges {
              context
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('insight'), { id: @props.insight }).then =>
      @setState
        ready: true


  gatherAttributes: (insight) ->
    uuid:           insight.get('uuid')
    parent_id:      insight.get('parent_id')
    pinnable_id:    insight.get('pinnable_id')
    pinnable_type:  insight.get('pinnable_type')
    title:          insight.get('content')


  # Spec/Lifecycle
  #

  componentWillMount: ->
    @cursor =
      insight: PinStore.cursor.items.cursor(@props.insight)

    @fetch()


  getInitialState: ->
    ready: false


  # Renderers
  #

  renderInsightContent: ->
    <span className="content" dangerouslySetInnerHTML={ __html: @cursor.insight.get('content') } />


  renderInsightContext: ->
    [
      <a key="company" href={ @cursor.insight.getIn(['context', 'company', 'url']) } className="company">
        { @cursor.insight.getIn(['context', 'company', 'title']) }
      </a>
      <strong key="comma">, </strong>
      <a key="post" href={ @cursor.insight.getIn(['context', 'post', 'url']) } className="post">
        { @cursor.insight.getIn(['context', 'post', 'title']) }
      </a>
    ]


  renderInsight: ->
    <section className="pin cloud-card">
      <article className="insight">
        <p className="insight-content">
          { @renderInsightContent() }
          &mdash;
          { @renderInsightContext() }
        </p>

        <footer>
          <span />
          <ul className="round-buttons">
            <EditPinButton uuid={ @cursor.insight.get('uuid') } />
            <SharePinButton insight={ @cursor.insight.deref().toJS() } />
            <PinButton {...@gatherAttributes(@cursor.insight)} />
          </ul>
        </footer>
      </article>
    </section>


  renderPlaceholder: ->
    <section className="pin cloud-card placeholder" />


  render: ->
    if @state.ready then @renderInsight() else @renderPlaceholder()
