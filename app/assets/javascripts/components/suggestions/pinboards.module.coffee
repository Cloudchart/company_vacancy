# @cjsx React.DOM

GlobalState = require('global_state/state')

Pinboard      = require('components/cards/pinboard_card')

UserStore     = require('stores/user_store.cursor')
PinboardStore = require('stores/pinboard_store')


module.exports = React.createClass

  displayName: 'SuggestedPinboards'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      viewer: ->
        """
          Viewer {
            related_pinboards {
              #{Pinboard.getQuery('pinboard')}
            },
            edges {
              related_pinboards
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('viewer')).then =>
      @setState
        ready: true


  createPackery: ->
    @packery = new Packery @getDOMNode(),
      transitionDuration: '0s'
      itemSelector: '.cloud-column'


  handleUpdate: ->
    cancelAnimationFrame @packery_timeout

    @packery_timeout = requestAnimationFrame =>
      @packery.reloadItems()
      @packery.layout()


  handleClick: (pinboard_id, event) ->
    event.preventDefault()

    @props.onSelect(pinboard_id)


  componentDidMount: ->
    @fetch()
    @createPackery()


  componentWillUnmount: ->
    clearTimeout @packery_timeout
    @packery.off()


  componentDidUpdate: ->
    @handleUpdate()


  getDefaultProps: ->
    onSelect: ->
    cursor:
      user:       UserStore.me()
      pinboards:  PinboardStore.cursor.items


  getInitialState: ->
    ready: false


  renderPlaceholder: (_, i) ->
    <section key={ i } className="cloud-column">
      <section className="cloud-card placeholder pinboard" />
    </section>


  renderPinboard: (pinboard) ->
    pinboard_id = pinboard.get('id')
    handleClick = @handleClick.bind(@, pinboard_id)

    <section key={ pinboard_id } className="cloud-column" onClick={ handleClick }>
      <Pinboard className="hoverable" pinboard={ pinboard_id } shouldRenderFollowButton={ false } />
    </section>


  renderPinboards: ->
    if @state.ready
      related_pinboards = @props.cursor.user.get('related_pinboards', Immutable.Seq())

      related_pinboards
        .filter (pinboard) -> pinboard.get('pins_count', 0) > 0
        .sortBy (pinboard) -> pinboard.get('title')
        .map @renderPinboard

    else
      Immutable.Repeat('placeholder', 2).map @renderPlaceholder


  render: ->
    <section className="pinboards cloud-columns cloud-columns-flex">
      { @renderPinboards().toArray() }
    </section>
